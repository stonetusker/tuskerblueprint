"""Tests for OpenTelemetry tracing integration."""

from __future__ import annotations

import importlib
import io
import json
import logging

from fastapi.testclient import TestClient
from opentelemetry import trace
from opentelemetry.sdk.trace.export import SimpleSpanProcessor
from opentelemetry.sdk.trace.export.in_memory_span_exporter import InMemorySpanExporter

from app.logging_config import JsonFormatter


def test_json_logs_include_trace_and_correlation_ids() -> None:
    """Verify the JSON log contract carries fields used by Alloy ingest parsing."""
    record = logging.LogRecord(
        name="test-service",
        level=logging.INFO,
        pathname=__file__,
        lineno=1,
        msg="request_completed",
        args=(),
        exc_info=None,
    )
    record.correlation_id = "correlation-123"
    record.trace_id = "trace-123"

    payload = json.loads(JsonFormatter().format(record))

    assert payload["level"] == "info"
    assert payload["correlation_id"] == "correlation-123"
    assert payload["trace_id"] == "trace-123"


def test_request_log_contains_trace_and_correlation_ids(monkeypatch) -> None:
    """Verify a real request log contains the fields parsed by Alloy."""
    monkeypatch.setenv("DEMO_FAILURE_MODE", "none")

    import app.main as app_main

    stream = io.StringIO()
    handler = logging.StreamHandler(stream)
    handler.setFormatter(JsonFormatter())
    app_main.logger.addHandler(handler)
    try:
        response = TestClient(app_main.app).get(
            "/api/v1/status",
            headers={"X-Correlation-ID": "request-log-correlation-id"},
        )
    finally:
        app_main.logger.removeHandler(handler)

    assert response.status_code == 200
    logs = [json.loads(line) for line in stream.getvalue().splitlines()]
    request_log = next(log for log in logs if log["message"] == "request_completed")
    assert request_log["correlation_id"] == "request-log-correlation-id"
    assert request_log["trace_id"]


def test_request_produces_span_with_correlation_id(monkeypatch) -> None:
    """Verify that HTTP requests generate spans with correlation_id attribute."""
    monkeypatch.setenv("DEMO_FAILURE_MODE", "none")
    monkeypatch.setenv("OTEL_EXPORTER_OTLP_ENDPOINT", "http://localhost:4317")

    in_memory_exporter = InMemorySpanExporter()
    test_tracer_provider = trace.get_tracer_provider()
    test_tracer_provider.add_span_processor(SimpleSpanProcessor(in_memory_exporter))

    import app.main as app_main

    importlib.reload(app_main)
    client = TestClient(app_main.app)

    test_correlation_id = "test-correlation-id-12345"
    response = client.get(
        "/api/v1/status",
        headers={"X-Correlation-ID": test_correlation_id},
    )

    assert response.status_code == 200
    assert response.headers["x-correlation-id"] == test_correlation_id

    spans = in_memory_exporter.get_finished_spans()
    assert len(spans) > 0
    assert any(span.attributes.get("correlation_id") == test_correlation_id for span in spans)


def test_auto_generated_correlation_id_in_span(monkeypatch) -> None:
    """Verify that auto-generated correlation IDs are properly handled."""
    monkeypatch.setenv("DEMO_FAILURE_MODE", "none")

    from app.main import app  # noqa: F401, E402

    client = TestClient(app)

    # Make a request without providing a correlation ID
    response = client.get("/api/v1/status")

    assert response.status_code == 200
    # Verify that a correlation ID was generated and returned
    correlation_id = response.headers.get("x-correlation-id")
    assert correlation_id
    assert len(correlation_id) > 0


def test_correlation_id_max_length(monkeypatch) -> None:
    """Verify that correlation IDs are truncated to 128 characters."""
    monkeypatch.setenv("DEMO_FAILURE_MODE", "none")

    from app.main import app  # noqa: F401, E402

    client = TestClient(app)

    # Make a request with a correlation ID longer than 128 characters
    long_correlation_id = "x" * 200
    response = client.get(
        "/api/v1/status",
        headers={"X-Correlation-ID": long_correlation_id},
    )

    assert response.status_code == 200
    returned_correlation_id = response.headers.get("x-correlation-id")
    assert returned_correlation_id
    assert len(returned_correlation_id) == 128


def test_latency_histogram_has_trace_exemplar(monkeypatch) -> None:
    """Verify the request latency histogram includes the current trace ID as an exemplar."""
    monkeypatch.setenv("DEMO_FAILURE_MODE", "none")

    import app.main as app_main

    client = TestClient(app_main.app)
    response = client.get(
        "/api/v1/status",
        headers={"X-Correlation-ID": "trace-exemplar-correlation-id"},
    )

    assert response.status_code == 200
    trace_ids = set()
    for metric in app_main.REQUEST_LATENCY.collect():
        for sample in metric.samples:
            exemplar = getattr(sample, "exemplar", None)
            if exemplar is not None:
                trace_ids.add(exemplar.labels.get("traceID"))

    assert any(trace_ids)


def test_notification_request_includes_correlation_id(monkeypatch) -> None:
    """Verify that notification requests include correlation_id in the response."""
    monkeypatch.setenv("DEMO_FAILURE_MODE", "none")

    from app.main import NOTIFICATION_STORE, NOTIFICATION_STORE_LOCK, app

    with NOTIFICATION_STORE_LOCK:
        NOTIFICATION_STORE.clear()

    client = TestClient(app)

    test_correlation_id = "test-notification-trace-id"
    response = client.post(
        "/api/v1/notifications",
        headers={"X-Correlation-ID": test_correlation_id},
        json={
            "channel": "email",
            "recipient": "test@example.invalid",
            "message": "Test message with tracing",
        },
    )

    assert response.status_code == 202
    payload = response.json()
    assert payload["correlation_id"] == test_correlation_id
    assert response.headers["x-correlation-id"] == test_correlation_id
