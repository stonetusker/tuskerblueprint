#!/usr/bin/env python3
from __future__ import annotations

import re
import sys
from pathlib import Path

sha = sys.argv[1] if len(sys.argv) == 2 else ""
if not re.fullmatch(r"[0-9a-f]{40}", sha):
    raise SystemExit("usage: set-release.py <40-character-git-sha>")

path = Path("deploy/overlays/development/kustomization.yaml")
text = path.read_text(encoding="utf-8")
text, tag_count = re.subn(r"(?m)^(\s*newTag:\s*).+$", rf"\g<1>{sha}", text, count=1)
text, annotation_count = re.subn(
    r"(?m)^(\s*tuskerblueprint\.io/release-sha:\s*).+$",
    rf"\g<1>{sha}",
    text,
    count=1,
)
if tag_count != 1 or annotation_count != 1:
    raise SystemExit("release fields were not found exactly once")
path.write_text(text, encoding="utf-8")
