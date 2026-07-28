"""Customer Notification API used in the StoneTusker delivery-platform demo."""

from __future__ import annotations

import asyncio
import logging
import time
import uuid
from datetime import UTC, datetime
from enum import Enum
from typing import Annotated

from fastapi import FastAPI, Header, HTTPException, Request, Response, status
from fastapi.responses import JSONResponse
from prometheus_client import CONTENT_TYPE_LATEST, Counter, Gauge, Histogram, generate_latest
from pydantic import BaseModel, Field

from .config import Settings, get_failure_mode
from .logging_config import configure_logging

configure_logging()
logger = logging.getLogger("demo-service")
settings = Settings.from_environment()

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


NOTIFICATION_STORE: dict[str, NotificationRecord] = {}

app = FastAPI(
    title="StoneTusker Customer Notification API",
    description=(
        "A deterministic reference workload used to demonstrate secure CI, GitOps, "
        "observability, failure detection, and rollback. It does not send real messages."
    ),
    version="1.0.0",
)


@app.middleware("http")
async def request_observability(request: Request, call_next):  # type: ignore[no-untyped-def]
    started = time.perf_counter()
    correlation_id = request.headers.get("x-correlation-id") or str(uuid.uuid4())
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

    route = request.scope.get("route")
    route_path = getattr(route, "path", request.url.path)
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


@app.get("/", response_model=ServiceMetadata)
def root() -> ServiceMetadata:
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
    NOTIFICATION_STORE[notification_id] = record
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
    record = NOTIFICATION_STORE.get(notification_id)
    if record is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Notification not found")
    return record
