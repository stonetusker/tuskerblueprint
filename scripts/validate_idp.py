#!/usr/bin/env python3
"""Static validation for the split TuskerBlueprint platform repository."""

from __future__ import annotations

import json
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
    text = path.read_text(encoding="utf-8")
    return list(yaml.load_all(text, Loader=UniqueKeyLoader))


# Parse every maintained YAML source with duplicate-key protection. Raw Backstage
# template sources are rendered and validated separately.
for path in sorted(ROOT.rglob("*.yaml")) + sorted(ROOT.rglob("*.yml")):
    if any(part in {"__MACOSX", ".generated", "node_modules"} for part in path.parts):
        continue
    text = path.read_text(encoding="utf-8")
    if "{%" in text or "${{ values." in text:
        continue
    try:
        load_documents(path)
    except Exception as error:  # noqa: BLE001 - validation must report every YAML error
        errors.append(f"{path.relative_to(ROOT)}: {error}")

required = [
    ".gitleaks.toml",
    ".github/workflows/idp-validation.yml",
    ".github/workflows/backstage-image.yml",
    "catalog-info.yaml",
    "software-templates/tusker-service/template.yaml",
    "software-templates/tusker-service/skeleton/service/app/main.py",
    "software-templates/tusker-service/skeleton/service/.github/CODEOWNERS",
    "software-templates/tusker-service/skeleton/service/.github/workflows/ci.yml",
    "software-templates/tusker-service/skeleton/service/docs/index.md",
    "software-templates/tusker-service/skeleton/service/docs/FIRST-RELEASE.md",
    "software-templates/tusker-service/skeleton/service/scripts/validate_repository.py",
    "software-templates/tusker-service/skeleton/service/deploy/base/external-secret.yaml",
    "software-templates/tusker-service/skeleton/service/mkdocs.yml",
    "software-templates/tusker-service/skeleton/service/catalog-info.yaml",
    "gitops/applications/workloads/demo-service/application-development.yaml",
    "gitops/applications/workloads/generated-workloads-application.yaml",
    "gitops/applications/platform/security/github-access/application-development.yaml",
    "platform-services/github-access/manifests/cluster-secret-store.yaml",
    "platform-services/backstage/manifests/ghcr-pull-external-secret.yaml",
    "platform-services/grafana/values/development.yaml",
    "scripts/backstage/configure-github-platform-secret.sh",
    "scripts/backstage/verify-github-platform-secrets.sh",
    "docs/GITHUB-CREDENTIALS-AND-PRIVATE-ACCESS.md",
    "scripts/backstage/set-backstage-release.py",
    "docs/REPOSITORY-SPLIT-AND-DEVELOPER-FLOW.md",
    "docs/DEVELOPER-DEMO-WORKFLOW.md",
    "docs/SETUP-FROM-SCRATCH.md",
    "docs/SECURITY-HISTORY-REMEDIATION.md",
    "docs/SCAFFOLDED-SERVICE-ACCEPTANCE.md",
    "infrastructure/ansible/inventories/dev/hosts.example.yml",
]
for relative in required:
    check((ROOT / relative).is_file(), f"missing {relative}")

check(
    not (ROOT / "workloads/demo-service").exists(),
    "platform repository still contains demo application source",
)
check(
    not (ROOT / "apis/demo-service").exists(),
    "platform repository still contains demo application OpenAPI source",
)
check(
    "/infrastructure/ansible/inventories/*/hosts.yml"
    in (ROOT / ".gitignore").read_text(encoding="utf-8"),
    "real Ansible inventory is not ignored",
)
kubectl_role = (
    ROOT / "infrastructure/ansible/roles/kubectl/tasks/main.yml"
).read_text(encoding="utf-8")
check("{{ ansible_host }}" in kubectl_role, "kubeconfig endpoint is hard-coded")
k3s_defaults = (
    ROOT / "infrastructure/ansible/roles/k3s/defaults/main.yml"
).read_text(encoding="utf-8")
check("--write-kubeconfig-mode=600" in k3s_defaults, "k3s kubeconfig mode is not private")

for cache_name in ("__pycache__", ".pytest_cache", ".mypy_cache", ".ruff_cache"):
    for cache_path in ROOT.rglob(cache_name):
        errors.append(f"generated cache directory committed: {cache_path.relative_to(ROOT)}")
for artifact_name in (".coverage", "coverage.xml"):
    for artifact_path in ROOT.rglob(artifact_name):
        errors.append(f"generated test artifact committed: {artifact_path.relative_to(ROOT)}")



def validate_kustomize_references() -> None:
    """Confirm local Kustomize references resolve before Argo CD sees them."""

    for kustomization in ROOT.rglob("kustomization.yaml"):
        text = kustomization.read_text(encoding="utf-8")
        if "{%" in text or "${{ values." in text:
            continue
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
            local_reference = reference.split("=", 1)[-1]
            check(
                (base / local_reference).resolve().exists(),
                f"{kustomization.relative_to(ROOT)} references missing {reference}",
            )


validate_kustomize_references()

# Root catalog locations must either resolve locally or be explicit HTTPS URLs.
root_catalog_documents = load_documents(ROOT / "catalog-info.yaml")
root_location = root_catalog_documents[0]
for target in root_location.get("spec", {}).get("targets", []):
    if str(target).startswith("https://"):
        continue
    check((ROOT / str(target)).resolve().is_file(), f"catalog target does not exist: {target}")

# Local catalog references should resolve to a local entity.
entities: dict[tuple[str, str, str], Path] = {}
for path in sorted((ROOT / "catalog").rglob("*.yaml")):
    for document in load_documents(path):
        if not isinstance(document, dict) or not document.get("kind"):
            continue
        metadata = document.get("metadata", {})
        key = (
            str(document["kind"]).lower(),
            str(metadata.get("namespace", "default")).lower(),
            str(metadata.get("name", "")).lower(),
        )
        check(bool(key[2]), f"catalog entity has no metadata.name: {path.relative_to(ROOT)}")
        check(key not in entities, f"duplicate catalog entity {key}: {path.relative_to(ROOT)}")
        entities[key] = path


def normalize_ref(value: str, default_kind: str) -> tuple[str, str, str]:
    kind = default_kind
    namespace = "default"
    name = value
    if ":" in value:
        kind, name = value.split(":", 1)
    if "/" in name:
        namespace, name = name.split("/", 1)
    return kind.lower(), namespace.lower(), name.lower()


for key, path in entities.items():
    document = load_documents(path)[0]
    spec = document.get("spec", {}) if isinstance(document, dict) else {}
    scalar_relations = {
        "owner": "group",
        "system": "system",
        "domain": "domain",
    }
    for field, default_kind in scalar_relations.items():
        value = spec.get(field)
        if value:
            ref = normalize_ref(str(value), default_kind)
            check(ref in entities, f"{path.relative_to(ROOT)} unresolved {field}: {value}")
    for field, default_kind in (("dependsOn", "component"), ("providesApis", "api")):
        for value in spec.get(field, []) or []:
            ref = normalize_ref(str(value), default_kind)
            check(ref in entities, f"{path.relative_to(ROOT)} unresolved {field}: {value}")

manifest = (ROOT / "gitops/applications/workloads/demo-service/application-development.yaml").read_text(
    encoding="utf-8"
)
check(
    "https://github.com/stonetusker/tusker-demo-notification-service.git" in manifest,
    "demo Argo CD Application does not use external repository",
)
check("path: deploy/overlays/development" in manifest, "demo Argo CD path is incorrect")
check("project: workloads" in manifest, "demo Argo CD Application uses the wrong project")

root_catalog = (ROOT / "catalog-info.yaml").read_text(encoding="utf-8")
check(
    "tusker-demo-notification-service/blob/main/catalog-info.yaml" in root_catalog,
    "external demo catalog location missing",
)

template = (ROOT / "software-templates/tusker-service/template.yaml").read_text(encoding="utf-8")
for marker in (
    "fetch:template",
    "publish:github",
    "catalog:register",
    "publish:github:pull-request",
    "collaborators:",
    "developerUsername",
):
    check(marker in template, f"template missing {marker}")

for marker in (
    "repositoryVisibility",
    "default: private",
    "repoVisibility: ${{ parameters.repositoryVisibility }}",
):
    check(marker in template, f"template visibility support missing {marker}")

ci = (
    ROOT / "software-templates/tusker-service/skeleton/service/.github/workflows/ci.yml"
).read_text(encoding="utf-8")
for marker in (
    "--no-git",
    "docker push",
    "scripts/set-release.py",
    "create-pull-request@v8",
    "actions/checkout@v7",
    "aquasec/trivy:0.70.0",
    "semgrep/semgrep:1.162.0",
    "zricethezav/gitleaks:v8.30.1",
):
    check(marker in ci, f"generated CI missing {marker}")
check("upload-sarif" not in ci, "generated CI requires GitHub Advanced Security")
check("security-events:" not in ci, "generated CI requests unused Advanced Security permission")
check("verify-public-package" not in ci, "generated CI still contains the public-only GHCR gate")

generated_sa = (ROOT / "software-templates/tusker-service/skeleton/service/deploy/base/service-account.yaml").read_text(encoding="utf-8")
check("name: ghcr-pull-secret" in generated_sa, "generated ServiceAccount lacks GHCR pull Secret")
generated_external_secret = (ROOT / "software-templates/tusker-service/skeleton/service/deploy/base/external-secret.yaml").read_text(encoding="utf-8")
check("kind: ExternalSecret" in generated_external_secret, "generated ExternalSecret missing")
check("kubernetes-platform-secrets" in generated_external_secret, "generated ExternalSecret uses wrong store")

backstage_sa = (ROOT / "platform-services/backstage/manifests/service-account.yaml").read_text(encoding="utf-8")
check("name: ghcr-pull-secret" in backstage_sa, "Backstage ServiceAccount lacks GHCR pull Secret")
backstage_external_secret = (ROOT / "platform-services/backstage/manifests/ghcr-pull-external-secret.yaml").read_text(encoding="utf-8")
check("kind: ExternalSecret" in backstage_external_secret, "Backstage GHCR ExternalSecret missing")
cluster_store = (ROOT / "platform-services/github-access/manifests/cluster-secret-store.yaml").read_text(encoding="utf-8")
check("remoteNamespace: platform-secrets" in cluster_store, "GitHub access store uses wrong source namespace")
for required_store_marker in (
    "conditions:",
    "platform.stonetusker.com/workload",
    "- backstage",
):
    check(
        required_store_marker in cluster_store,
        f"ClusterSecretStore is missing access restriction: {required_store_marker}",
    )
check(
    'resourceNames: ["ghcr-pull-credentials"]'
    in (ROOT / "platform-services/github-access/manifests/role.yaml").read_text(encoding="utf-8"),
    "GHCR source Secret RBAC is not name-scoped",
)
check(
    (ROOT / "software-templates/tusker-service/skeleton/service/deploy/base/external-secret.yaml").is_file(),
    "generated GHCR ExternalSecret missing",
)

credential_script = (ROOT / "scripts/backstage/configure-github-platform-secret.sh").read_text(encoding="utf-8")
for marker in (
    "GHCR PAT classic with read:packages",
    "--from-file=GITHUB_TOKEN",
    "--type=kubernetes.io/dockerconfigjson",
    "GHCR_PULL_TOKEN",
    "umask 077",
):
    check(marker in credential_script, f"credential bootstrap script missing {marker}")
check("--from-literal" not in credential_script, "credential bootstrap exposes values through command-line literals")

credential_verifier = (ROOT / "scripts/backstage/verify-github-platform-secrets.sh").read_text(encoding="utf-8")
for marker in (
    "repo-creds",
    "kubernetes.io/dockerconfigjson",
    "ClusterSecretStore",
    "externalsecret.external-secrets.io",
):
    check(marker in credential_verifier, f"credential verifier missing {marker}")

backstage_ci = (ROOT / ".github/workflows/backstage-image.yml").read_text(encoding="utf-8")
for marker in (
    "packages: write",
    "pull-requests: write",
    'NODE_VERSION: "22.21.0"',
    "aquasec/trivy:0.70.0",
    "actions/upload-artifact@v7",
    "docker/login-action@v4",
    "scripts/backstage/set-backstage-release.py",
    "create-pull-request@v8",
):
    check(marker in backstage_ci, f"Backstage workflow missing {marker}")
check("Verify anonymous Backstage image pull" not in backstage_ci, "Backstage CI still requires a public package")
backstage_bootstrap = (
    ROOT / "scripts/backstage/bootstrap-custom-app.sh"
).read_text(encoding="utf-8")
check("@backstage/create-app@latest" not in backstage_bootstrap, "Backstage generator is unpinned")
check(
    'BACKSTAGE_CREATE_APP_VERSION="0.9.0"' in backstage_bootstrap,
    "Backstage generator baseline is unexpected",
)
check(
    not (ROOT / "scripts/demo/configure-ghcr-pull-secret.sh").exists(),
    "legacy namespace-by-namespace GHCR Secret helper must not be present",
)
demo_preflight = (ROOT / "scripts/demo/preflight.sh").read_text(encoding="utf-8")
check(
    "demo-service-development/ghcr-pull-secret is missing" in demo_preflight,
    "demo preflight does not require the platform-managed pull Secret",
)
check(
    "expected when the package is public" not in demo_preflight,
    "demo preflight still allows the old public-only bypass",
)

grafana_values = load_documents(ROOT / "platform-services/grafana/values/development.yaml")[0]
dashboard_json = grafana_values.get("dashboards", {}).get("default", {}).get(
    "tusker-service-overview", {}
).get("json")

if isinstance(dashboard_json, str):
    try:
        dashboard = json.loads(dashboard_json)
    except json.JSONDecodeError as error:
        errors.append(f"Grafana service dashboard JSON is invalid: {error}")
    else:
        check(
            dashboard.get("uid") == "tusker-service-overview",
            "Grafana service dashboard UID is unstable",
        )
        variable_names = {
            item.get("name")
            for item in dashboard.get("templating", {}).get("list", [])
            if isinstance(item, dict)
        }
        check(
            {"environment", "service"}.issubset(variable_names),
            "Grafana service dashboard variables are incomplete",
        )
        panel_titles = {
            panel.get("title")
            for panel in dashboard.get("panels", [])
            if isinstance(panel, dict)
        }
        for title in (
            "Replica availability",
            "Request rate",
            "5xx error percentage",
            "p95 latency",
            "Running release",
            "Application logs",
        ):
            check(title in panel_titles, f"Grafana service dashboard missing {title}")
else:
    # Allow dashboards to be provisioned via a ConfigMap generator (kustomize)
    kustomize_path = ROOT / "platform-services/grafana/dashboards/development/kustomization.yaml"
    if not kustomize_path.exists():
        errors.append("Grafana service dashboard is not provisioned")
    else:
        try:
            kdoc = load_documents(kustomize_path)[0]
        except Exception as error:
            errors.append(f"{kustomize_path.relative_to(ROOT)}: {error}")
            kdoc = {}
        config_generators = kdoc.get("configMapGenerator", []) or []
        # Expect a generator that produces the dashboard ConfigMap
        generator_names = {g.get("name") for g in config_generators if isinstance(g, dict)}
        check(
            "grafana-dashboard-demo-service" in generator_names,
            "Grafana dashboard ConfigMap generator not found",
        )
        # Ensure the dashboard file exists
        dashboard_file = ROOT / "platform-services/grafana/dashboards/development/demo-service-delivery.json"
        check(dashboard_file.is_file(), "Grafana dashboard file demo-service-delivery.json is missing")

requirements = (
    ROOT / "software-templates/tusker-service/skeleton/service/requirements.txt"
).read_text(encoding="utf-8")
check("fastapi==0.141.1" in requirements, "generated dependency baseline is incorrect")
check("prometheus-client==0.26.0" in requirements, "generated Prometheus client baseline is incorrect")
check("starlette==1.4.1" in requirements, "generated Starlette baseline is incorrect")
check("uvicorn[standard]==0.52.1" in requirements, "generated Uvicorn baseline is incorrect")

# Persistent Secret manifests are not allowed in either repository.
for path in sorted(ROOT.rglob("*.yaml")) + sorted(ROOT.rglob("*.yml")):
    if "skeleton" in path.parts:
        continue
    text = path.read_text(encoding="utf-8")
    if "{%" in text or "${{ values." in text:
        continue
    try:
        documents = load_documents(path)
    except Exception:
        continue
    for document in documents:
        if isinstance(document, dict) and document.get("kind") == "Secret":
            errors.append(
                f"Kubernetes Secret manifest must not be committed: {path.relative_to(ROOT)}"
            )

if errors:
    for error in errors:
        print(f"ERROR: {error}")
    raise SystemExit(1)
print("TuskerBlueprint split-repository validation passed")
