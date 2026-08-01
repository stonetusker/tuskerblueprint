"""Customer Notification API used in the StoneTusker delivery-platform demo."""

from __future__ import annotations

import asyncio
import logging
import time
import uuid
from collections import OrderedDict
from datetime import UTC, datetime
from enum import Enum
from pathlib import Path
from threading import Lock
from typing import Annotated

from fastapi import FastAPI, Header, HTTPException, Query, Request, Response, status
from fastapi.responses import FileResponse, JSONResponse
from fastapi.staticfiles import StaticFiles
from prometheus_client import CONTENT_TYPE_LATEST, Counter, Gauge, Histogram, generate_latest
from pydantic import BaseModel, Field

from .config import Settings, get_failure_mode
from .logging_config import configure_logging

configure_logging()
settings = Settings.from_environment()
logger = logging.getLogger(settings.service_name)
STATIC_DIR = Path(__file__).resolve().parent / "static"

REQUESTS = Counter(
    "http_requests_total",
    "Total HTTP requests handled by the demo service",
    ["service", "environment", "method", "route", "status"],
)
REQUEST_LATENCY = Histogram(
    "http_request_duration_seconds",
    "HTTP request duration in seconds",
    ["service", "environment", "method", "route"],
)
NOTIFICATIONS = Counter(
    "notification_requests_total",
    "Accepted notification requests",
    ["service", "environment", "channel"],
)
APPLICATION_INFO = Gauge(
    "application_info",
    "Static information about the running application release",
    ["service", "environment", "version"],
)
APPLICATION_INFO.labels(
    service=settings.service_name,
    environment=settings.environment,
    version=settings.version,
).set(1)


class NotificationChannel(str, Enum):
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

app = FastAPI(
    title="${{ values.name }}",
    description=(
        "${{ values.description }}. This reference workload demonstrates secure CI, GitOps, "
        "observability, failure detection, and rollback. It does not send real messages."
    ),
    version="1.2.0",
)
app.mount("/assets", StaticFiles(directory=STATIC_DIR), name="assets")


@app.middleware("http")
async def request_observability(request: Request, call_next):  # type: ignore[no-untyped-def]
    started = time.perf_counter()
    supplied_correlation_id = request.headers.get("x-correlation-id", "").strip()
    correlation_id = supplied_correlation_id[:128] or str(uuid.uuid4())
    request.state.correlation_id = correlation_id
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

    REQUESTS.labels(
        service=settings.service_name,
        environment=settings.environment,
        method=request.method,
        route=route_path,
        status=str(response.status_code),
    ).inc()
    REQUEST_LATENCY.labels(
        service=settings.service_name,
        environment=settings.environment,
        method=request.method,
        route=route_path,
    ).observe(elapsed)

    logger.info(
        "request_completed",
        extra={
            "service": settings.service_name,
            "environment": settings.environment,
            "version": settings.version,
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
    return Response(generate_latest(), media_type=CONTENT_TYPE_LATEST)


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
