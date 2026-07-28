#!/usr/bin/env python3
"""Update one demo-service Kustomize overlay to an immutable release SHA."""

from __future__ import annotations

import argparse
import re
from pathlib import Path

SHA_RE = re.compile(r"^[0-9a-f]{40}$")


def update_release(path: Path, sha: str) -> None:
    if not SHA_RE.fullmatch(sha):
        raise SystemExit("release must be a full 40-character lowercase Git SHA")

    original = path.read_text(encoding="utf-8")
    updated, tag_count = re.subn(
        r"(?m)^(\s*newTag:\s*).+$",
        rf"\g<1>{sha}",
        original,
        count=1,
    )
    updated, annotation_count = re.subn(
        r"(?m)^(\s*tuskerblueprint\.io/release-sha:\s*).+$",
        rf"\g<1>{sha}",
        updated,
        count=1,
    )

    if tag_count != 1 or annotation_count != 1:
        raise SystemExit(
            f"expected one newTag and one release annotation in {path}; "
            f"found newTag={tag_count}, annotation={annotation_count}"
        )

    path.write_text(updated, encoding="utf-8")


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--environment", choices=["development", "staging", "production"], required=True)
    parser.add_argument("--release", required=True)
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
    update_release(path, args.release)
    print(f"Updated {path} to release {args.release}")


if __name__ == "__main__":
    main()
