from __future__ import annotations

from fastapi.testclient import TestClient

from app.main import NOTIFICATION_STORE, app

client = TestClient(app)


def setup_function() -> None:
    NOTIFICATION_STORE.clear()


def test_root_contains_release_metadata(monkeypatch) -> None:
    monkeypatch.setenv("DEMO_FAILURE_MODE", "none")
    response = client.get("/")
    assert response.status_code == 200
    payload = response.json()
    assert payload["service"] == "demo-service"
    assert payload["status"] == "ok"
    assert response.headers["x-correlation-id"]
    assert response.headers["x-service-version"]


def test_health_and_readiness(monkeypatch) -> None:
    monkeypatch.setenv("DEMO_FAILURE_MODE", "none")
    assert client.get("/healthz").json() == {"status": "ok"}
    assert client.get("/readyz").json() == {"status": "ready"}


def test_controlled_readiness_failure(monkeypatch) -> None:
    monkeypatch.setenv("DEMO_FAILURE_MODE", "readiness")
    response = client.get("/readyz")
    assert response.status_code == 503
    assert response.json()["detail"] == "Controlled readiness failure"


def test_notification_round_trip(monkeypatch) -> None:
    monkeypatch.setenv("DEMO_FAILURE_MODE", "none")
    created = client.post(
        "/api/v1/notifications",
        headers={"X-Demo-Request": "pytest"},
        json={
            "channel": "email",
            "recipient": "demo@example.invalid",
            "message": "Delivery-platform demonstration",
        },
    )
    assert created.status_code == 202
    notification_id = created.json()["id"]

    fetched = client.get(f"/api/v1/notifications/{notification_id}")
    assert fetched.status_code == 200
    assert fetched.json()["state"] == "accepted"
    assert fetched.json()["correlation_id"]


def test_controlled_api_error(monkeypatch) -> None:
    monkeypatch.setenv("DEMO_FAILURE_MODE", "errors")
    response = client.post(
        "/api/v1/notifications",
        json={
            "channel": "webhook",
            "recipient": "https://example.invalid/demo",
            "message": "This request is expected to fail",
        },
    )
    assert response.status_code == 500
    assert response.json()["detail"] == "Controlled demo failure"


def test_metrics_endpoint(monkeypatch) -> None:
    monkeypatch.setenv("DEMO_FAILURE_MODE", "none")
    response = client.get("/metrics")
    assert response.status_code == 200
    assert "application_info" in response.text
    assert "http_requests_total" in response.text
