from fastapi.testclient import TestClient

from src.main import app

client = TestClient(app)


def test_root() -> None:
    response = client.get("/")
    assert response.status_code == 200
    assert response.json()["service"] == "${{ values.name }}"
    assert response.headers["x-correlation-id"]


def test_health_and_readiness(monkeypatch) -> None:
    monkeypatch.setenv("DEMO_FAILURE_MODE", "none")
    assert client.get("/healthz").status_code == 200
    assert client.get("/readyz").status_code == 200


def test_metrics() -> None:
    response = client.get("/metrics")
    assert response.status_code == 200
    assert "application_info" in response.text
