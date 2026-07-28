from __future__ import annotations

import os
from dataclasses import dataclass


@dataclass(frozen=True, slots=True)
class Settings:
    service_name: str = os.getenv("SERVICE_NAME", "${{ values.name }}")
    environment: str = os.getenv("APP_ENV", "local")
    version: str = os.getenv("APP_VERSION", "development")


def failure_mode() -> str:
    value = os.getenv("DEMO_FAILURE_MODE", "none").strip().lower()
    return value if value in {"none", "readiness", "errors", "latency"} else "none"
