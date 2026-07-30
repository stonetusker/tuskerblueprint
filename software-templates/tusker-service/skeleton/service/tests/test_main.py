from fastapi.testclient import TestClient

from src.main import app

client = TestClient(app)


def test_ui_and_status() -> None:
    ui_response = client.get("/")
    assert ui_response.status_code == 200
    assert "${{ values.name }}" in ui_response.text
    assert ui_response.headers["content-security-policy"]

    response = client.get("/api/v1/status")
    assert response.status_code == 200
    assert response.json()["service"] == "${{ values.name }}"
    assert response.headers["x-correlation-id"]


def test_static_assets() -> None:
    assert client.get("/assets/styles.css").status_code == 200
    assert client.get("/assets/app.js").status_code == 200


def test_health_and_readiness(monkeypatch) -> None:
    monkeypatch.setenv("DEMO_FAILURE_MODE", "none")
    assert client.get("/healthz").status_code == 200
    assert client.get("/readyz").status_code == 200


def test_example_endpoint() -> None:
    response = client.get("/api/v1/example")
    assert response.status_code == 200
    assert response.json()["service"] == "${{ values.name }}"


def test_metrics() -> None:
    response = client.get("/metrics")
    assert response.status_code == 200
    assert "application_info" in response.text
