#!/usr/bin/env python3
"""Set a controlled demo failure mode in a Kustomize overlay."""

from __future__ import annotations

import argparse
import re
from pathlib import Path

MODES = {"none", "readiness", "errors", "latency"}


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--environment", choices=["development", "staging", "production"], default="development")
    parser.add_argument("--mode", choices=sorted(MODES), required=True)
    parser.add_argument("--repo-root", default=".")
    args = parser.parse_args()

    path = (
        Path(args.repo_root)
        / "workloads"
        / "demo-service"
        / "overlays"
        / args.environment
        / "kustomization.yaml"
    )
    original = path.read_text(encoding="utf-8")
    updated, count = re.subn(
        r"(?m)^(\s*- DEMO_FAILURE_MODE=).+$",
        rf"\g<1>{args.mode}",
        original,
        count=1,
    )
    if count != 1:
        raise SystemExit(f"expected exactly one DEMO_FAILURE_MODE entry in {path}")

    path.write_text(updated, encoding="utf-8")
    print(f"Set {args.environment} failure mode to {args.mode} in {path}")


if __name__ == "__main__":
    main()
