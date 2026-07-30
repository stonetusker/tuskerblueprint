from __future__ import annotations

import asyncio
import logging
import time
import uuid
from pathlib import Path

from fastapi import FastAPI, HTTPException, Request, Response, status
from fastapi.responses import FileResponse, JSONResponse
from fastapi.staticfiles import StaticFiles
from prometheus_client import CONTENT_TYPE_LATEST, Counter, Gauge, Histogram, generate_latest

from .config import Settings, failure_mode

settings = Settings()
logging.basicConfig(level=logging.INFO, format="%(message)s")
logger = logging.getLogger(settings.service_name)
STATIC_DIR = Path(__file__).resolve().parent / "static"

REQUESTS = Counter(
    "http_requests_total",
    "Total HTTP requests",
    ["service", "environment", "method", "route", "status"],
)
LATENCY = Histogram(
    "http_request_duration_seconds",
    "HTTP request duration",
    ["service", "environment", "method", "route"],
)
INFO = Gauge(
    "application_info",
    "Application release information",
    ["service", "environment", "version"],
)
INFO.labels(settings.service_name, settings.environment, settings.version).set(1)

app = FastAPI(title="${{ values.name }}", description="${{ values.description }}", version="1.1.0")
app.mount("/assets", StaticFiles(directory=STATIC_DIR), name="assets")


@app.middleware("http")
async def observe(request: Request, call_next):  # type: ignore[no-untyped-def]
    started = time.perf_counter()
    correlation_id = request.headers.get("x-correlation-id") or str(uuid.uuid4())
    mode = failure_mode()

    if mode == "latency" and request.url.path.startswith("/api/"):
        await asyncio.sleep(2.5)

    if mode == "errors" and request.url.path.startswith("/api/"):
        response: Response = JSONResponse(
            status_code=500,
            content={"detail": "Controlled demo failure", "correlation_id": correlation_id},
        )
    else:
        response = await call_next(request)

    response.headers["X-Correlation-ID"] = correlation_id
    response.headers["X-Service-Version"] = settings.version
    response.headers.setdefault("X-Content-Type-Options", "nosniff")
    response.headers.setdefault("Referrer-Policy", "no-referrer")
    response.headers.setdefault("X-Frame-Options", "DENY")
    response.headers.setdefault("Permissions-Policy", "camera=(), geolocation=(), microphone=()")
    response.headers.setdefault(
        "Content-Security-Policy",
        "default-src 'self'; base-uri 'none'; frame-ancestors 'none'; "
        "form-action 'self'; img-src 'self' data:; script-src 'self'; "
        "style-src 'self'; connect-src 'self'",
    )

    route = getattr(request.scope.get("route"), "path", request.url.path)
    elapsed = time.perf_counter() - started
    REQUESTS.labels(
        settings.service_name,
        settings.environment,
        request.method,
        route,
        str(response.status_code),
    ).inc()
    LATENCY.labels(
        settings.service_name,
        settings.environment,
        request.method,
        route,
    ).observe(elapsed)
    logger.info(
        '{"event":"request_completed","service":"%s","environment":"%s",'
        '"version":"%s","correlation_id":"%s","method":"%s","path":"%s",'
        '"status_code":%d,"duration_ms":%.2f}',
        settings.service_name,
        settings.environment,
        settings.version,
        correlation_id,
        request.method,
        request.url.path,
        response.status_code,
        elapsed * 1000,
    )
    return response


@app.get("/", include_in_schema=False)
def application_ui() -> FileResponse:
    return FileResponse(STATIC_DIR / "index.html", media_type="text/html")


@app.get("/api/v1/status")
def service_status() -> dict[str, str]:
    return {
        "service": settings.service_name,
        "environment": settings.environment,
        "version": settings.version,
        "status": "ok",
        "description": "${{ values.description }}",
    }


@app.get("/healthz")
def health() -> dict[str, str]:
    return {"status": "ok"}


@app.get("/readyz")
def readiness() -> dict[str, str]:
    if failure_mode() == "readiness":
        raise HTTPException(status_code=status.HTTP_503_SERVICE_UNAVAILABLE, detail="Not ready")
    return {"status": "ready"}


@app.get("/metrics", include_in_schema=False)
def metrics() -> Response:
    return Response(generate_latest(), media_type=CONTENT_TYPE_LATEST)


@app.get("/api/v1/example")
def example() -> dict[str, str]:
    return {
        "message": "Replace this endpoint with product behavior.",
        "service": settings.service_name,
        "environment": settings.environment,
        "version": settings.version,
    }
