from __future__ import annotations

from fastapi.testclient import TestClient

from app.main import NOTIFICATION_STORE, NOTIFICATION_STORE_LOCK, app

client = TestClient(app)


def setup_function() -> None:
    with NOTIFICATION_STORE_LOCK:
        NOTIFICATION_STORE.clear()


def test_ui_and_release_metadata(monkeypatch) -> None:
    monkeypatch.setenv("DEMO_FAILURE_MODE", "none")

    ui_response = client.get("/")
    assert ui_response.status_code == 200
    assert "Stonetusker Customer Experience Hub" in ui_response.text
    assert "Turn a customer message into" in ui_response.text
    assert ui_response.headers["cache-control"] == "no-store, max-age=0"
    assert ui_response.headers["content-security-policy"]
    assert ui_response.headers["x-content-type-options"] == "nosniff"

    head_response = client.head("/")
    assert head_response.status_code == 200
    assert head_response.headers["content-type"].startswith("text/html")

    status_response = client.get("/api/v1/status")
    payload = status_response.json()
    assert payload["service"] == "${{ values.name }}"
    assert payload["status"] == "ok"
    assert status_response.headers["x-correlation-id"]
    assert status_response.headers["x-service-version"]


def test_static_assets() -> None:
    css_response = client.get("/assets/styles.css")
    js_response = client.get("/assets/app.js")
    logo_response = client.get("/assets/stonetusker-logo.svg")

    assert css_response.status_code == 200
    assert "--brand" in css_response.text
    assert "--coral" in css_response.text

    assert js_response.status_code == 200
    assert "submitNotification" in js_response.text

    assert logo_response.status_code == 200
    assert logo_response.headers["content-type"].startswith("image/svg+xml")
    assert "<svg" in logo_response.text


def test_interactive_docs_csp_and_unmatched_metric(monkeypatch) -> None:
    monkeypatch.setenv("DEMO_FAILURE_MODE", "none")

    docs_response = client.get("/docs")
    assert docs_response.status_code == 200
    docs_csp = docs_response.headers["content-security-policy"]
    assert "https://cdn.jsdelivr.net" in docs_csp
    assert "'unsafe-inline'" in docs_csp

    assert client.get("/this-route-does-not-exist").status_code == 404
    metrics_response = client.get("/metrics")
    assert 'route="<unmatched>"' in metrics_response.text


def test_health_and_readiness(monkeypatch) -> None:
    monkeypatch.setenv("DEMO_FAILURE_MODE", "none")
    assert client.get("/healthz").json() == {"status": "ok"}
    assert client.get("/readyz").json() == {"status": "ready"}


def test_controlled_readiness_failure(monkeypatch) -> None:
    monkeypatch.setenv("DEMO_FAILURE_MODE", "readiness")
    response = client.get("/readyz")
    assert response.status_code == 503
    assert response.json()["detail"] == "Controlled readiness failure"


def test_notification_round_trip_and_list(monkeypatch) -> None:
    monkeypatch.setenv("DEMO_FAILURE_MODE", "none")
    created = client.post(
        "/api/v1/notifications",
        headers={"X-Demo-Request": "pytest", "X-Correlation-ID": "pytest-correlation"},
        json={
            "channel": "email",
            "recipient": "demo@example.invalid",
            "message": "Delivery-platform demonstration",
        },
    )
    assert created.status_code == 202
    notification_id = created.json()["id"]
    assert created.json()["correlation_id"] == "pytest-correlation"

    listed = client.get("/api/v1/notifications?limit=5")
    assert listed.status_code == 200
    assert len(listed.json()) == 1
    assert listed.json()[0]["id"] == notification_id

    fetched = client.get(f"/api/v1/notifications/{notification_id}")
    assert fetched.status_code == 200
    assert fetched.json()["state"] == "accepted"
    assert fetched.json()["correlation_id"] == "pytest-correlation"


def test_notification_list_limit_validation(monkeypatch) -> None:
    monkeypatch.setenv("DEMO_FAILURE_MODE", "none")
    assert client.get("/api/v1/notifications?limit=0").status_code == 422
    assert client.get("/api/v1/notifications?limit=51").status_code == 422


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
