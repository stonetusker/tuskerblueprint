"""Customer Notification API used in the Stonetusker delivery-platform demo."""

from __future__ import annotations

import asyncio
import logging
import os
import time
import uuid
from collections import OrderedDict
from datetime import UTC, datetime
from enum import StrEnum
from pathlib import Path
from threading import Lock
from typing import Annotated

from fastapi import FastAPI, Header, HTTPException, Query, Request, Response, status
from fastapi.responses import FileResponse, JSONResponse
from fastapi.staticfiles import StaticFiles
from opentelemetry import trace
from opentelemetry.exporter.otlp.proto.grpc.trace_exporter import OTLPSpanExporter
from opentelemetry.instrumentation.fastapi import FastAPIInstrumentor
from opentelemetry.sdk.resources import Resource
from opentelemetry.sdk.trace import TracerProvider
from opentelemetry.sdk.trace.export import BatchSpanProcessor
from opentelemetry.trace import ProxyTracerProvider
from prometheus_client import (
    CONTENT_TYPE_LATEST,
    CollectorRegistry,
    Counter,
    Gauge,
    Histogram,
    generate_latest,
)
from pydantic import BaseModel, Field

from .config import Settings, get_failure_mode
from .logging_config import configure_logging

configure_logging()
settings = Settings.from_environment()
logger = logging.getLogger(settings.service_name)
STATIC_DIR = Path(__file__).resolve().parent / "static"

# Initialize OpenTelemetry tracing
resource = Resource.create(
    {
        "service.name": settings.service_name,
        "deployment.environment": settings.environment,
    }
)

otlp_exporter = OTLPSpanExporter(
    endpoint=os.getenv("OTEL_EXPORTER_OTLP_ENDPOINT", "http://localhost:4317"),
)
current_provider = trace.get_tracer_provider()
tracer_provider: trace.TracerProvider
if isinstance(current_provider, ProxyTracerProvider):
    sdk_tracer_provider = TracerProvider(resource=resource)
    sdk_tracer_provider.add_span_processor(BatchSpanProcessor(otlp_exporter))
    trace.set_tracer_provider(sdk_tracer_provider)
    tracer_provider = sdk_tracer_provider
else:
    tracer_provider = current_provider

# Auto-instrument FastAPI
app = FastAPI(
    title="${{ values.name }}",
    description=(
        "${{ values.description }}. "
        "This reference workload demonstrates secure CI, GitOps, "
        "observability, failure detection, and rollback. It does not send real messages."
    ),
    version="1.2.0",
)
FastAPIInstrumentor.instrument_app(app, tracer_provider=tracer_provider)

PROMETHEUS_REGISTRY = CollectorRegistry()

REQUESTS = Counter(
    "http_requests_total",
    "Total HTTP requests handled by the demo service",
    ["service", "environment", "method", "route", "status"],
    registry=PROMETHEUS_REGISTRY,
)
REQUEST_LATENCY = Histogram(
    "http_request_duration_seconds",
    "HTTP request duration in seconds",
    ["service", "environment", "method", "route"],
    registry=PROMETHEUS_REGISTRY,
)
NOTIFICATIONS = Counter(
    "notification_requests_total",
    "Accepted notification requests",
    ["service", "environment", "channel"],
    registry=PROMETHEUS_REGISTRY,
)
APPLICATION_INFO = Gauge(
    "application_info",
    "Static information about the running application release",
    ["service", "environment", "version"],
    registry=PROMETHEUS_REGISTRY,
)
APPLICATION_INFO.labels(
    service=settings.service_name,
    environment=settings.environment,
    version=settings.version,
).set(1)


class NotificationChannel(StrEnum):
    email = "email"
    sms = "sms"
    webhook = "webhook"


class NotificationRequest(BaseModel):
    channel: NotificationChannel
    recipient: Annotated[str, Field(min_length=3, max_length=200)]
    message: Annotated[str, Field(min_length=1, max_length=2000)]


class NotificationRecord(BaseModel):
    id: str
    channel: NotificationChannel
    recipient: str
    message: str
    state: str
    accepted_at: datetime
    correlation_id: str


class ServiceMetadata(BaseModel):
    service: str
    environment: str
    version: str
    status: str


MAX_NOTIFICATION_RECORDS = 500
NOTIFICATION_STORE: OrderedDict[str, NotificationRecord] = OrderedDict()
NOTIFICATION_STORE_LOCK = Lock()
NOTIFICATION_STORE_RECORDS = Gauge(
    "notification_store_records",
    "Current number of retained demo notification records",
    ["service", "environment"],
    registry=PROMETHEUS_REGISTRY,
)


def sync_notification_store_metric() -> None:
    """Keep the retained-record gauge aligned with the bounded in-memory store."""
    with NOTIFICATION_STORE_LOCK:
        current_size = len(NOTIFICATION_STORE)
    NOTIFICATION_STORE_RECORDS.labels(
        service=settings.service_name,
        environment=settings.environment,
    ).set(current_size)


def get_current_trace_id() -> str | None:
    """Return the current OpenTelemetry trace ID for Prometheus exemplars."""
    current_span = trace.get_current_span()
    span_context = current_span.get_span_context()
    if not span_context or not span_context.is_valid:
        return None
    return format(span_context.trace_id, "032x")


sync_notification_store_metric()


app.mount("/assets", StaticFiles(directory=STATIC_DIR), name="assets")


@app.middleware("http")
async def request_observability(request: Request, call_next):  # type: ignore[no-untyped-def]
    started = time.perf_counter()
    supplied_correlation_id = request.headers.get("x-correlation-id", "").strip()
    correlation_id = supplied_correlation_id[:128] or str(uuid.uuid4())
    request.state.correlation_id = correlation_id

    current_span = trace.get_current_span()
    if current_span and current_span.is_recording():
        current_span.set_attribute("correlation_id", correlation_id)

    mode = get_failure_mode()

    if mode == "latency" and request.url.path.startswith("/api/"):
        await asyncio.sleep(settings.failure_delay_ms / 1000)

    if mode == "errors" and request.url.path.startswith("/api/"):
        response: Response = JSONResponse(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            content={
                "detail": "Controlled demo failure",
                "correlation_id": correlation_id,
            },
        )
    else:
        response = await call_next(request)

    response.headers["X-Correlation-ID"] = correlation_id
    response.headers["X-Service-Version"] = settings.version
    response.headers.setdefault("X-Content-Type-Options", "nosniff")
    response.headers.setdefault("Referrer-Policy", "no-referrer")
    response.headers.setdefault("X-Frame-Options", "DENY")
    response.headers.setdefault("Permissions-Policy", "camera=(), geolocation=(), microphone=()")
    if request.url.path in {"/docs", "/redoc", "/docs/oauth2-redirect"}:
        content_security_policy = (
            "default-src 'self'; base-uri 'none'; frame-ancestors 'none'; "
            "form-action 'self'; img-src 'self' data: https://fastapi.tiangolo.com; "
            "script-src 'self' 'unsafe-inline' https://cdn.jsdelivr.net; "
            "style-src 'self' 'unsafe-inline' https://cdn.jsdelivr.net; "
            "font-src 'self' data: https://cdn.jsdelivr.net; connect-src 'self'"
        )
    else:
        content_security_policy = (
            "default-src 'self'; base-uri 'none'; frame-ancestors 'none'; "
            "form-action 'self'; img-src 'self' data:; script-src 'self'; "
            "style-src 'self'; connect-src 'self'"
        )
    response.headers.setdefault("Content-Security-Policy", content_security_policy)

    route = request.scope.get("route")
    route_path = getattr(route, "path", None) or "<unmatched>"
    elapsed = time.perf_counter() - started
    trace_id = get_current_trace_id()

    REQUESTS.labels(
        service=settings.service_name,
        environment=settings.environment,
        method=request.method,
        route=route_path,
        status=str(response.status_code),
    ).inc()
    request_latency = REQUEST_LATENCY.labels(
        service=settings.service_name,
        environment=settings.environment,
        method=request.method,
        route=route_path,
    )
    if trace_id:
        request_latency.observe(elapsed, exemplar={"traceID": trace_id})
    else:
        request_latency.observe(elapsed)

    logger.info(
        "request_completed",
        extra={
            "service": settings.service_name,
            "environment": settings.environment,
            "version": settings.version,
            "trace_id": trace_id,
            "correlation_id": correlation_id,
            "method": request.method,
            "path": request.url.path,
            "route": route_path,
            "status_code": response.status_code,
            "duration_ms": round(elapsed * 1000, 2),
            "failure_mode": mode,
        },
    )
    return response


@app.get("/", include_in_schema=False)
def application_ui() -> FileResponse:
    return FileResponse(
        STATIC_DIR / "index.html",
        media_type="text/html",
        headers={"Cache-Control": "no-store, max-age=0"},
    )


@app.head("/", include_in_schema=False)
def application_ui_head() -> Response:
    return Response(
        status_code=status.HTTP_200_OK,
        media_type="text/html",
        headers={"Cache-Control": "no-store, max-age=0"},
    )


@app.get("/api/v1/status", response_model=ServiceMetadata)
def service_status() -> ServiceMetadata:
    return ServiceMetadata(
        service=settings.service_name,
        environment=settings.environment,
        version=settings.version,
        status="ok",
    )


@app.get("/healthz")
def health() -> dict[str, str]:
    return {"status": "ok"}


@app.get("/readyz")
def readiness() -> dict[str, str]:
    if get_failure_mode() == "readiness":
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="Controlled readiness failure",
        )
    return {"status": "ready"}


@app.get("/metrics", include_in_schema=False)
def metrics() -> Response:
    return Response(generate_latest(PROMETHEUS_REGISTRY), media_type=CONTENT_TYPE_LATEST)


@app.get("/api/v1/notifications", response_model=list[NotificationRecord])
def list_notifications(
    limit: Annotated[int, Query(ge=1, le=50)] = 10,
) -> list[NotificationRecord]:
    with NOTIFICATION_STORE_LOCK:
        records = list(NOTIFICATION_STORE.values())
    return list(reversed(records[-limit:]))


@app.post(
    "/api/v1/notifications",
    response_model=NotificationRecord,
    status_code=status.HTTP_202_ACCEPTED,
)
def create_notification(
    payload: NotificationRequest,
    request: Request,
    x_demo_request: Annotated[str | None, Header()] = None,
) -> NotificationRecord:
    notification_id = str(uuid.uuid4())
    record = NotificationRecord(
        id=notification_id,
        channel=payload.channel,
        recipient=payload.recipient,
        message=payload.message,
        state="accepted",
        accepted_at=datetime.now(UTC),
        correlation_id=request.state.correlation_id,
    )
    with NOTIFICATION_STORE_LOCK:
        NOTIFICATION_STORE[notification_id] = record
        NOTIFICATION_STORE.move_to_end(notification_id)
        while len(NOTIFICATION_STORE) > MAX_NOTIFICATION_RECORDS:
            NOTIFICATION_STORE.popitem(last=False)

    sync_notification_store_metric()

    NOTIFICATIONS.labels(
        service=settings.service_name,
        environment=settings.environment,
        channel=payload.channel.value,
    ).inc()

    logger.info(
        "notification_accepted",
        extra={
            "service": settings.service_name,
            "environment": settings.environment,
            "version": settings.version,
            "notification_id": notification_id,
            "channel": payload.channel.value,
            "trace_id": get_current_trace_id(),
            "correlation_id": request.state.correlation_id,
            "demo_request": x_demo_request or "unspecified",
        },
    )
    return record


@app.get("/api/v1/notifications/{notification_id}", response_model=NotificationRecord)
def get_notification(notification_id: str) -> NotificationRecord:
    with NOTIFICATION_STORE_LOCK:
        record = NOTIFICATION_STORE.get(notification_id)
    if record is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Notification not found")
    return record
