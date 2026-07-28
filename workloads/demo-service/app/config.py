"""Runtime configuration for the demo service.

Configuration is intentionally environment driven so the same immutable image can
be promoted across environments without being rebuilt.
"""

from __future__ import annotations

import os
from dataclasses import dataclass
from typing import Literal

FailureMode = Literal["none", "readiness", "errors", "latency"]


@dataclass(frozen=True, slots=True)
class Settings:
    service_name: str
    environment: str
    version: str
    failure_delay_ms: int

    @classmethod
    def from_environment(cls) -> Settings:
        delay_raw = os.getenv("FAILURE_DELAY_MS", "2500")
        try:
            delay = max(0, min(int(delay_raw), 30_000))
        except ValueError:
            delay = 2500

        return cls(
            service_name=os.getenv("SERVICE_NAME", "demo-service"),
            environment=os.getenv("APP_ENV", "local"),
            version=os.getenv("APP_VERSION", "development"),
            failure_delay_ms=delay,
        )


def get_failure_mode() -> FailureMode:
    """Read the failure mode per request so demonstrations can be tested safely."""

    value = os.getenv("DEMO_FAILURE_MODE", "none").strip().lower()
    if value in {"none", "readiness", "errors", "latency"}:
        return value  # type: ignore[return-value]
    return "none"
