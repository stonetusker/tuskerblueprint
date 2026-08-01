#!/usr/bin/env python3
"""Static validation for the standalone notification-service repository."""

from __future__ import annotations

import re
from pathlib import Path
from typing import Any

import yaml

ROOT = Path(__file__).resolve().parents[1]
errors: list[str] = []


class UniqueKeyLoader(yaml.SafeLoader):
    """YAML loader that rejects duplicate mapping keys."""


def construct_unique_mapping(
    loader: UniqueKeyLoader,
    node: yaml.MappingNode,
    deep: bool = False,
) -> dict[Any, Any]:
    mapping: dict[Any, Any] = {}
    for key_node, value_node in node.value:
        key = loader.construct_object(key_node, deep=deep)
        if key in mapping:
            raise yaml.constructor.ConstructorError(
                "while constructing a mapping",
                node.start_mark,
                f"found duplicate key {key!r}",
                key_node.start_mark,
            )
        mapping[key] = loader.construct_object(value_node, deep=deep)
    return mapping


UniqueKeyLoader.add_constructor(
    yaml.resolver.BaseResolver.DEFAULT_MAPPING_TAG,
    construct_unique_mapping,
)


def check(condition: bool, message: str) -> None:
    if not condition:
        errors.append(message)


def load_documents(path: Path) -> list[Any]:
    return list(yaml.load_all(path.read_text(encoding="utf-8"), Loader=UniqueKeyLoader))


for path in sorted(ROOT.rglob("*.yaml")) + sorted(ROOT.rglob("*.yml")):
    if any(part in {".git", ".venv", "node_modules"} for part in path.parts):
        continue
    try:
        load_documents(path)
    except Exception as error:  # noqa: BLE001 - validation must report every YAML error
        errors.append(f"{path.relative_to(ROOT)}: {error}")


def validate_kustomize_references() -> None:
    """Confirm that every local Kustomize file reference exists."""

    for kustomization in ROOT.rglob("kustomization.yaml"):
        document = load_documents(kustomization)[0] or {}
        base = kustomization.parent
        references: list[str] = []
        for field in ("resources", "components", "patchesStrategicMerge"):
            references.extend(str(item) for item in document.get(field, []) or [])
        for item in document.get("patches", []) or []:
            if isinstance(item, dict) and item.get("path"):
                references.append(str(item["path"]))
        for generator in ("configMapGenerator", "secretGenerator"):
            for item in document.get(generator, []) or []:
                if not isinstance(item, dict):
                    continue
                for field in ("files", "envs"):
                    references.extend(str(value) for value in item.get(field, []) or [])
        for reference in references:
            if reference.startswith(("http://", "https://", "git::")):
                continue
            # configMapGenerator file entries may use key=path.
            local_reference = reference.split("=", 1)[-1]
            check(
                (base / local_reference).resolve().exists(),
                f"{kustomization.relative_to(ROOT)} references missing {reference}",
            )


validate_kustomize_references()

required = [
    ".gitleaks.toml",
    "app/main.py",
    "app/static/index.html",
    "app/static/styles.css",
    "app/static/app.js",
    "app/static/stonetusker-logo.svg",
    "tests/test_main.py",
    "Dockerfile",
    "catalog-info.yaml",
    "openapi.yaml",
    "mkdocs.yml",
    ".github/CODEOWNERS",
    ".github/PULL_REQUEST_TEMPLATE.md",
    ".github/dependabot.yml",
    ".github/workflows/ci.yml",
    ".github/workflows/platform-validation.yml",
    "deploy/base/kustomization.yaml",
    "scripts/set-release.py",
    "docs/CODE-REVIEW.md",
    "docs/FIRST-RELEASE.md",
]
for relative in required:
    check((ROOT / relative).is_file(), f"missing {relative}")

mkdocs = load_documents(ROOT / "mkdocs.yml")[0]


def flatten(value: Any):
    if isinstance(value, str):
        yield value
    elif isinstance(value, list):
        for item in value:
            yield from flatten(item)
    elif isinstance(value, dict):
        for item in value.values():
            yield from flatten(item)


for item in flatten(mkdocs.get("nav", [])):
    check((ROOT / mkdocs.get("docs_dir", "docs") / item).is_file(), f"missing docs/{item}")

sha_or_bootstrap = re.compile(r'newTag:\s*(?:"?[0-9a-f]{40}"?|main)\s*$', re.MULTILINE)
for environment in ("development", "staging", "production"):
    path = ROOT / f"deploy/overlays/{environment}/kustomization.yaml"
    check(path.is_file(), f"missing {path.relative_to(ROOT)}")
    if path.is_file():
        text = path.read_text(encoding="utf-8")
        check("newTag: latest" not in text, f"{environment} uses latest")
        check(bool(sha_or_bootstrap.search(text)), f"{environment} has an invalid image tag")

ci = (ROOT / ".github/workflows/ci.yml").read_text(encoding="utf-8")
for marker in (
    "--no-git",
    "image --scanners vuln",
    "--format spdx-json",
    "docker push",
    "scripts/set-release.py",
    "create-pull-request@v8",
    "actions/checkout@v6",
    "actions/setup-python@v6",
    "actions/upload-artifact@v7",
    "docker/login-action@v4",
    "aquasec/trivy:0.70.0",
    "semgrep/semgrep:1.162.0",
    "zricethezav/gitleaks:v8.30.1",
):
    check(marker in ci, f"CI missing {marker}")
check("upload-sarif" not in ci, "CI uses GitHub Advanced Security SARIF upload")
check("security-events:" not in ci, "CI requests unused GitHub Advanced Security permission")

requirements = (ROOT / "requirements.txt").read_text(encoding="utf-8")
check("fastapi==0.141.1" in requirements, "FastAPI pin is not the reviewed version")
check("starlette==1.3.1" in requirements, "Starlette pin is not the reviewed version")

dockerfile = (ROOT / "Dockerfile").read_text(encoding="utf-8")
for marker in ("USER 10001:10001", "--no-cache-dir", "HEALTHCHECK"):
    check(marker in dockerfile, f"Dockerfile missing {marker}")

catalog_documents = load_documents(ROOT / "catalog-info.yaml")
kinds = {str(item.get("kind", "")) for item in catalog_documents if isinstance(item, dict)}
check({"Component", "API"}.issubset(kinds), "catalog-info.yaml must define Component and API")
check("backstage.io/techdocs-ref: dir:." in (ROOT / "catalog-info.yaml").read_text(), "TechDocs annotation missing")

service_account = (ROOT / "deploy/base/service-account.yaml").read_text(encoding="utf-8")
check("imagePullSecrets:" in service_account, "ServiceAccount does not reference an image pull Secret")
check("name: ghcr-pull-secret" in service_account, "ServiceAccount uses the wrong image pull Secret")
external_secret = (ROOT / "deploy/base/external-secret.yaml").read_text(encoding="utf-8")
check("kind: ExternalSecret" in external_secret, "GHCR ExternalSecret missing")
check("name: kubernetes-platform-secrets" in external_secret, "ExternalSecret uses the wrong ClusterSecretStore")
check("verify-public-package" not in ci, "CI still contains the public-only GHCR gate")

for path in sorted(ROOT.rglob("*.yaml")) + sorted(ROOT.rglob("*.yml")):
    try:
        documents = load_documents(path)
    except Exception:
        continue
    for document in documents:
        if isinstance(document, dict) and document.get("kind") == "Secret":
            errors.append(
                f"Kubernetes Secret manifest must not be committed: {path.relative_to(ROOT)}"
            )

for cache_name in ("__pycache__", ".pytest_cache", ".mypy_cache", ".ruff_cache"):
    for cache_path in ROOT.rglob(cache_name):
        errors.append(f"generated cache directory committed: {cache_path.relative_to(ROOT)}")
for artifact_name in (".coverage", "coverage.xml", "gitleaks.sarif", "semgrep.sarif", "sbom.spdx.json"):
    for artifact_path in ROOT.rglob(artifact_name):
        errors.append(f"generated test artifact committed: {artifact_path.relative_to(ROOT)}")

if errors:
    for error in errors:
        print(f"ERROR: {error}")
    raise SystemExit(1)
print("Application repository validation passed")
