#!/usr/bin/env python3
"""Update the development Backstage image to an immutable Git commit SHA."""

from __future__ import annotations

import argparse
import re
from pathlib import Path

DEFAULT_VALUES_FILE = Path("platform-services/backstage/values/development-idp.yaml")
SHA_PATTERN = re.compile(r"^[0-9a-f]{40}$")
TAG_PATTERN = re.compile(r'(?m)^(\s+tag:\s*)["\']?[0-9a-f]{40}["\']?\s*$')


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("release", help="Full 40-character lowercase Git SHA")
    parser.add_argument("--values-file", type=Path, default=DEFAULT_VALUES_FILE)
    args = parser.parse_args()

    if not SHA_PATTERN.fullmatch(args.release):
        raise SystemExit("release must be a full 40-character lowercase Git SHA")
    if not args.values_file.is_file():
        raise SystemExit(f"values file not found: {args.values_file}")

    original = args.values_file.read_text(encoding="utf-8")
    updated, replacements = TAG_PATTERN.subn(rf'\g<1>"{args.release}"', original, count=1)
    if replacements != 1:
        raise SystemExit("expected exactly one immutable Backstage image tag")

    args.values_file.write_text(updated, encoding="utf-8")
    print(f"Updated {args.values_file} to {args.release}")


if __name__ == "__main__":
    main()
