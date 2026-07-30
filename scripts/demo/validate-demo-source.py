#!/usr/bin/env python3
"""Offline source validation for the StoneTusker delivery-platform demo.

The validator is intentionally safe to run from a normal working repository.
It validates maintained source and ignores generated applications, dependency
folders, virtual environments, build output, and test caches.

Coverage is enforced when pytest-cov is available. When it is not installed,
the validator still runs the application tests and prints a warning; GitHub
Actions installs requirements-dev.txt and enforces the coverage gate.
"""

from __future__ import annotations

import importlib.util
import os
import re
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path
from typing import Any, Iterable

import yaml

ROOT = Path(__file__).resolve().parents[2]
ERRORS: list[str] = []
WARNINGS: list[str] = []
CHECKS = 0

IGNORED_PARTS = {
    ".git",
    ".generated",
    ".idea",
    ".mypy_cache",
    ".pytest_cache",
    ".ruff_cache",
    ".venv",
    ".vscode",
    ".yarn",
    "__MACOSX",
    "__pycache__",
    "build",
    "dist",
    "htmlcov",
    "node_modules",
    "reports",
    "venv",
}


class UniqueKeyLoader(yaml.SafeLoader):
    """YAML loader that rejects duplicate mapping keys."""


def _construct_mapping(
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
                f"duplicate key {key!r}",
                key_node.start_mark,
            )
        mapping[key] = loader.construct_object(value_node, deep=deep)
    return mapping


UniqueKeyLoader.add_constructor(
    yaml.resolver.BaseResolver.DEFAULT_MAPPING_TAG,
    _construct_mapping,
)


def check(condition: bool, message: str) -> None:
    global CHECKS
    CHECKS += 1
    if not condition:
        ERRORS.append(message)


def is_ignored(path: Path) -> bool:
    try:
        relative = path.relative_to(ROOT)
    except ValueError:
        relative = path
    return any(part in IGNORED_PARTS for part in relative.parts)


def source_files(pattern: str) -> Iterable[Path]:
    for path in ROOT.rglob(pattern):
        if not is_ignored(path):
            yield path


def load_yaml(path: Path) -> list[Any]:
    try:
        return list(
            yaml.load_all(
                path.read_text(encoding="utf-8"),
                Loader=UniqueKeyLoader,
            )
        )
    except Exception as exc:  # noqa: BLE001
        try:
            display = path.relative_to(ROOT)
        except ValueError:
            display = path
        ERRORS.append(f"YAML parse failed for {display}: {exc}")
        return []


def validate_yaml() -> None:
    paths = sorted(set(source_files("*.yml")) | set(source_files("*.yaml")))
    parsed = 0
    skipped_templates = 0
    for path in paths:
        text = path.read_text(encoding="utf-8", errors="replace")
        if "{%" in text:
            skipped_templates += 1
            continue
        if load_yaml(path):
            parsed += 1
    check(parsed > 0, "No maintained YAML files were parsed")
    print(
        f"YAML validation: {parsed} maintained files parsed; "
        f"{skipped_templates} raw Jinja templates deferred to rendered validation"
    )


def validate_python() -> None:
    targets = [
        ROOT / "workloads/demo-service/app",
        ROOT / "workloads/demo-service/tests",
        ROOT / "scripts/demo",
    ]
    compiled = 0
    for target in targets:
        for path in sorted(target.rglob("*.py")):
            if is_ignored(path):
                continue
            try:
                compile(
                    path.read_text(encoding="utf-8"),
                    str(path),
                    "exec",
                )
                compiled += 1
            except SyntaxError as exc:
                ERRORS.append(
                    f"Python compile failed for {path.relative_to(ROOT)}: {exc}"
                )
    check(compiled > 0, "No maintained Python files were compiled")
    print(f"Python syntax validation: {compiled} files")


def validate_kustomize_references() -> None:
    checked = 0
    for path in sorted(source_files("kustomization.yaml")):
        if "software-templates" in path.parts:
            continue
        docs = load_yaml(path)
        if not docs or not isinstance(docs[0], dict):
            continue
        checked += 1
        data = docs[0]
        for resource in data.get("resources", []) or []:
            if isinstance(resource, str) and resource.startswith(("http://", "https://")):
                continue
            target = (path.parent / resource).resolve()
            check(
                target.exists(),
                f"Missing resource {resource} referenced by {path.relative_to(ROOT)}",
            )
            if target.is_dir():
                check(
                    (target / "kustomization.yaml").exists()
                    or (target / "kustomization.yml").exists(),
                    f"Directory resource {target.relative_to(ROOT)} has no kustomization file",
                )

    base_docs = load_yaml(ROOT / "workloads/demo-service/base/deployment.yaml")
    if base_docs:
        base_deployment = base_docs[0]
        image = base_deployment["spec"]["template"]["spec"]["containers"][0]["image"]
        check(
            image.startswith("ghcr.io/stonetusker/tuskerblueprint-demo-service:"),
            "Demo Deployment does not use the expected GHCR image",
        )
        check(":latest" not in image, "Demo Deployment must not use :latest")

    for environment in ("development", "staging", "production"):
        overlay_path = (
            ROOT
            / "workloads"
            / "demo-service"
            / "overlays"
            / environment
            / "kustomization.yaml"
        )
        docs = load_yaml(overlay_path)
        if not docs:
            continue
        overlay = docs[0]
        images = overlay.get("images", [])
        check(
            len(images) == 1,
            f"{environment} overlay must contain exactly one image transform",
        )
        if images:
            check(
                images[0]["name"]
                == "ghcr.io/stonetusker/tuskerblueprint-demo-service",
                f"{environment} image transformer does not match the base image",
            )
            check(
                images[0].get("newTag") not in {None, "", "latest"},
                f"{environment} overlay must define a non-latest image tag",
            )
        annotations = overlay.get("commonAnnotations", {})
        check(
            "tuskerblueprint.io/release-sha" in annotations,
            f"{environment} overlay has no release SHA annotation",
        )

    print(f"Kustomize reference validation: {checked} maintained kustomizations")


def flatten_nav(nav: Any) -> Iterable[str]:
    if isinstance(nav, str):
        yield nav
    elif isinstance(nav, list):
        for item in nav:
            yield from flatten_nav(item)
    elif isinstance(nav, dict):
        for item in nav.values():
            yield from flatten_nav(item)


def validate_mkdocs(path: Path, root: Path = ROOT) -> None:
    docs = load_yaml(path)
    if not docs or not isinstance(docs[0], dict):
        return
    config = docs[0]
    docs_dir = str(config.get("docs_dir", "docs"))
    plugins = config.get("plugins", []) or []
    normalized_plugins = {
        item if isinstance(item, str) else next(iter(item), "")
        for item in plugins
        if isinstance(item, (str, dict))
    }
    check(
        "techdocs-core" in normalized_plugins,
        f"TechDocs configuration is missing techdocs-core: {path.relative_to(root)}",
    )
    for relative in flatten_nav(config.get("nav", [])):
        target = path.parent / docs_dir / relative
        check(
            target.exists(),
            f"TechDocs nav target is missing: {target.relative_to(root)}",
        )


def validate_openapi_and_docs() -> None:
    canonical_openapi = ROOT / "apis/demo-service/openapi.yaml"
    workload_openapi = ROOT / "workloads/demo-service/openapi.yaml"
    api_docs = load_yaml(canonical_openapi)
    check(bool(api_docs), "Demo OpenAPI could not be parsed")
    if api_docs:
        api = api_docs[0]
        check(api.get("openapi") == "3.0.3", "Demo OpenAPI version must be 3.0.3")
        for endpoint in (
            "/",
            "/api/v1/status",
            "/healthz",
            "/readyz",
            "/api/v1/notifications",
            "/api/v1/notifications/{notificationId}",
        ):
            check(endpoint in api.get("paths", {}), f"OpenAPI is missing {endpoint}")

    check(workload_openapi.exists(), "Workload OpenAPI copy is missing")
    if canonical_openapi.exists() and workload_openapi.exists():
        check(
            canonical_openapi.read_text(encoding="utf-8")
            == workload_openapi.read_text(encoding="utf-8"),
            "The catalog and workload OpenAPI copies have drifted",
        )

    validate_mkdocs(ROOT / "workloads/demo-service/mkdocs.yml")
    print("OpenAPI and TechDocs source validation: passed")


def validate_workflows() -> None:
    workflow = ROOT / ".github/workflows/demo-service-ci.yml"
    check(workflow.exists(), "Demo-service workflow is missing")
    if workflow.exists():
        text = workflow.read_text(encoding="utf-8")
        required = [
            "ruff format --check",
            "mypy app",
            "--cov=app",
            "zricethezav/gitleaks:v8.24.3",
            "gitleaks-demo-service.sarif",
            "semgrep/semgrep:1.100.0",
            "--entrypoint semgrep",
            "trivy fs",
            "trivy image",
            "--format spdx-json",
            "set-demo-release.py",
            "create-pull-request@v7",
        ]
        for marker in required:
            check(marker in text, f"Demo workflow is missing required marker: {marker}")
        check("@master" not in text, "Demo workflow contains an unpinned @master action")
        check(
            "gitleaks/gitleaks-action" not in text,
            "Demo workflow uses the licensed Gitleaks GitHub Action instead of the OSS CLI",
        )
        check(
            "python -m pip install semgrep" not in text,
            "Demo workflow installs Semgrep into runner Python instead of using the pinned container",
        )

    template_workflow = (
        ROOT
        / "software-templates/tusker-service/skeleton/service/.github/workflows/ci.yml"
    )
    check(template_workflow.exists(), "Generated-service workflow is missing")
    if template_workflow.exists():
        text = template_workflow.read_text(encoding="utf-8")
        check("--cov=src" in text, "Generated-service CI does not enforce coverage")
        check("paths:" in text, "Generated-service CI has no path filter")
        check(
            "deploy/overlays/development/**" not in text,
            "Generated-service CI path filter would retrigger on its own release PR",
        )
        check("@master" not in text, "Generated-service workflow contains @master")
        check(
            "zricethezav/gitleaks:v8.24.3" in text,
            "Generated-service workflow does not use the pinned OSS Gitleaks CLI image",
        )
        check(
            "gitleaks/gitleaks-action" not in text,
            "Generated-service workflow uses the licensed Gitleaks GitHub Action",
        )
        check(
            "semgrep/semgrep:1.100.0" in text,
            "Generated-service workflow does not use the pinned Semgrep container",
        )
        check(
            "--entrypoint semgrep" in text,
            "Generated-service workflow does not invoke the Semgrep container explicitly",
        )
        check(
            "python -m pip install semgrep" not in text,
            "Generated-service workflow installs Semgrep into runner Python",
        )

    template_platform_workflow = (
        ROOT
        / "software-templates/tusker-service/skeleton/service/.github/workflows/platform-validation.yml"
    )
    check(
        template_platform_workflow.exists(),
        "Generated-service metadata and GitOps validation workflow is missing",
    )
    if template_platform_workflow.exists():
        text = template_platform_workflow.read_text(encoding="utf-8")
        for marker in (
            "catalog-info.yaml",
            "mkdocs.yml",
            "deploy/**",
            "kubectl kustomize",
            "Validate YAML and TechDocs navigation",
        ):
            check(
                marker in text,
                f"Generated-service platform validation workflow is missing: {marker}",
            )

    demo_requirements = (
        ROOT / "workloads/demo-service/requirements-dev.txt"
    ).read_text(encoding="utf-8")
    template_requirements = (
        ROOT
        / "software-templates/tusker-service/skeleton/service/requirements-dev.txt"
    ).read_text(encoding="utf-8")
    check("pytest-cov" in demo_requirements, "Demo development dependencies omit pytest-cov")
    check(
        "pytest-cov" in template_requirements,
        "Generated-service development dependencies omit pytest-cov",
    )
    print("Workflow and test dependency validation: passed")


def validate_template_definition() -> None:
    path = ROOT / "software-templates/tusker-service/template.yaml"
    documents = load_yaml(path)
    check(bool(documents), "Tusker Service template could not be parsed")
    if not documents:
        return

    template = documents[0]
    parameters = template.get("spec", {}).get("parameters", [])
    properties: dict[str, Any] = {}
    for group in parameters:
        properties.update(group.get("properties", {}) or {})

    check(
        properties.get("developerUsername", {}).get("default") == "subeeshlearn",
        "Tusker Service template does not default to the demo developer subeeshlearn",
    )
    check(
        "repoVisibility" not in properties,
        "The complete buyer-demo template must use the supported public repository path",
    )

    steps = template.get("spec", {}).get("steps", [])
    actions = {step.get("id"): step for step in steps}
    required_actions = {
        "fetch-service": "fetch:template",
        "publish-service": "publish:github",
        "register-service": "catalog:register",
        "fetch-gitops": "fetch:template",
        "publish-gitops-pr": "publish:github:pull-request",
    }
    for step_id, action in required_actions.items():
        check(step_id in actions, f"Tusker Service template is missing step {step_id}")
        if step_id in actions:
            check(
                actions[step_id].get("action") == action,
                f"Tusker Service step {step_id} must use {action}",
            )

    publish_input = actions.get("publish-service", {}).get("input", {})
    check(
        "token" not in publish_input,
        "Service repository creation must use the Backstage platform credential",
    )
    collaborators = publish_input.get("collaborators", []) or []
    check(
        any(
            item.get("user") == "${{ parameters.developerUsername }}"
            and item.get("access") == "push"
            for item in collaborators
            if isinstance(item, dict)
        ),
        "Generated repository does not grant the selected developer push access",
    )

    gitops_input = actions.get("publish-gitops-pr", {}).get("input", {})
    check(
        "token" not in gitops_input,
        "GitOps onboarding must use the Backstage platform credential",
    )
    check(
        gitops_input.get("targetPath")
        == "gitops/generated-workloads/${{ parameters.name }}",
        "GitOps onboarding target path is incorrect",
    )
    print("Software-template action validation: passed")


def render_template_text(text: str, visibility: str = "public") -> str:
    conditional = re.compile(
        r"\{% if values\.repoVisibility != 'public' %\}(.*?)\{% endif %\}",
        re.DOTALL,
    )
    text = conditional.sub(
        lambda match: match.group(1) if visibility != "public" else "",
        text,
    )

    replacements = {
        "${{ values.name }}": "generated-demo-api",
        "${{ values.description }}": "Generated service validation fixture",
        "${{ values.owner }}": "group:default/developers",
        "${{ values.developerUsername }}": "subeeshlearn",
        "${{ values.system }}": "system:default/tuskerblueprint",
        "${{ values.port }}": "8000",
        "${{ values.repoVisibility }}": visibility,
        "${{ values.repoUrl | parseRepoUrl | pick('owner') }}": "stonetusker",
        "${{ values.repoUrl | parseRepoUrl | pick('repo') }}": "generated-demo-api",
    }
    for source, target in replacements.items():
        text = text.replace(source, target)

    escaped_expression = re.compile(r"\$\{\{\s*'\$\{\{\s*(.*?)\s*\}\}'\s*\}\}")
    return escaped_expression.sub(
        lambda match: "${{ " + match.group(1) + " }}",
        text,
    )


def pytest_command(test_path: str = "tests") -> list[str]:
    return [
        sys.executable,
        "-m",
        "pytest",
        "-o",
        "addopts=-q --strict-markers --disable-warnings",
        "-p",
        "no:cacheprovider",
        test_path,
    ]


def subprocess_test_environment(python_path: Path, temp_dir: Path) -> dict[str, str]:
    env = os.environ.copy()
    env["PYTHONPATH"] = str(python_path)
    env["PYTHONDONTWRITEBYTECODE"] = "1"
    env["PYTHONPYCACHEPREFIX"] = str(temp_dir / "pycache")
    env["COVERAGE_FILE"] = str(temp_dir / ".coverage")
    return env


def validate_rendered_template() -> None:
    skeleton = ROOT / "software-templates/tusker-service/skeleton/service"
    for visibility in ("public", "private"):
        with tempfile.TemporaryDirectory(prefix=f"tusker-template-{visibility}-") as tmp:
            temp_root = Path(tmp)
            rendered_root = temp_root / "generated-demo-api"
            for source in skeleton.rglob("*"):
                if is_ignored(source):
                    continue
                relative = source.relative_to(skeleton)
                destination = rendered_root / relative
                if source.is_dir():
                    destination.mkdir(parents=True, exist_ok=True)
                    continue
                destination.parent.mkdir(parents=True, exist_ok=True)
                text = source.read_text(encoding="utf-8")
                rendered = render_template_text(text, visibility=visibility)
                check(
                    "${{ values." not in rendered,
                    f"Unresolved value in {visibility} template file {relative}",
                )
                check(
                    "{%" not in rendered,
                    f"Unresolved conditional in {visibility} template file {relative}",
                )
                destination.write_text(rendered, encoding="utf-8")

            required_generated_files = [
                "README.md",
                "CONTRIBUTING.md",
                "SECURITY.md",
                ".gitignore",
                ".github/PULL_REQUEST_TEMPLATE.md",
                ".github/dependabot.yml",
                ".github/workflows/ci.yml",
                ".github/workflows/platform-validation.yml",
                "catalog-info.yaml",
                "openapi.yaml",
                "mkdocs.yml",
                "docs/architecture.md",
                "docs/development.md",
                "docs/delivery.md",
                "docs/runbook.md",
                "docs/observability.md",
                "docs/security.md",
                "scripts/verify.sh",
                "src/static/index.html",
                "src/static/styles.css",
                "src/static/app.js",
                "deploy/overlays/development/kustomization.yaml",
            ]
            for required in required_generated_files:
                check(
                    (rendered_root / required).is_file(),
                    f"Rendered {visibility} template is missing {required}",
                )

            yaml_paths = sorted(rendered_root.rglob("*.yaml")) + sorted(
                rendered_root.rglob("*.yml")
            )
            for path in yaml_paths:
                if not load_yaml(path):
                    ERRORS.append(
                        f"Rendered {visibility} template YAML failed: "
                        f"{path.relative_to(rendered_root)}"
                    )

            for path in sorted(rendered_root.rglob("*.py")):
                try:
                    compile(path.read_text(encoding="utf-8"), str(path), "exec")
                except SyntaxError as exc:
                    ERRORS.append(
                        f"Rendered {visibility} template Python failed for "
                        f"{path.relative_to(rendered_root)}: {exc}"
                    )

            deployment = (
                rendered_root / "deploy/base/deployment.yaml"
            ).read_text(encoding="utf-8")
            if visibility == "public":
                check(
                    "imagePullSecrets:" not in deployment,
                    "Public generated service unexpectedly requires ghcr-pull-secret",
                )
            else:
                check(
                    "imagePullSecrets:" in deployment,
                    "Private generated service is missing ghcr-pull-secret",
                )

            validate_mkdocs(rendered_root / "mkdocs.yml", root=rendered_root)

            env = subprocess_test_environment(rendered_root, temp_root)
            result = subprocess.run(
                pytest_command(),
                cwd=rendered_root,
                env=env,
                text=True,
                capture_output=True,
                check=False,
            )
            if result.returncode != 0:
                ERRORS.append(
                    f"Rendered {visibility} template tests failed:\n"
                    + result.stdout
                    + "\n"
                    + result.stderr
                )

    print("Rendered software-template validation: public and private variants passed")


def validate_live_app_tests() -> None:
    service = ROOT / "workloads/demo-service"
    if importlib.util.find_spec("pytest") is None:
        ERRORS.append(
            "pytest is not installed. Run: "
            "python3 -m pip install -r workloads/demo-service/requirements-dev.txt"
        )
        return

    coverage_available = (
        importlib.util.find_spec("pytest_cov") is not None
        and os.getenv("TUSKER_VALIDATOR_DISABLE_COVERAGE") != "1"
        and os.getenv("PYTEST_DISABLE_PLUGIN_AUTOLOAD", "").lower() not in {"1", "true"}
    )

    with tempfile.TemporaryDirectory(prefix="tusker-demo-tests-") as tmp:
        temp_root = Path(tmp)
        command = pytest_command()
        if coverage_available:
            command.extend(
                [
                    "--cov=app",
                    "--cov-branch",
                    "--cov-report=term-missing",
                    f"--cov-report=xml:{temp_root / 'coverage.xml'}",
                    "--cov-fail-under=85",
                ]
            )
        else:
            WARNINGS.append(
                "pytest-cov is not installed; application tests ran without the local "
                "coverage gate. GitHub Actions installs requirements-dev.txt and enforces 85%."
            )

        env = subprocess_test_environment(service, temp_root)
        result = subprocess.run(
            command,
            cwd=service,
            env=env,
            text=True,
            capture_output=True,
            check=False,
        )
        if result.returncode != 0:
            ERRORS.append(
                "Demo application tests failed:\n" + result.stdout + "\n" + result.stderr
            )
        else:
            print(result.stdout.strip())


def validate_release_updater() -> None:
    source = ROOT / "workloads/demo-service/overlays/development/kustomization.yaml"
    with tempfile.TemporaryDirectory(prefix="tusker-release-") as tmp:
        target_root = Path(tmp)
        target = target_root / source.relative_to(ROOT)
        target.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(source, target)
        sha = "a" * 40
        result = subprocess.run(
            [
                sys.executable,
                str(ROOT / "scripts/demo/set-demo-release.py"),
                "--repo-root",
                str(target_root),
                "--environment",
                "development",
                "--release",
                sha,
            ],
            text=True,
            capture_output=True,
            check=False,
        )
        check(result.returncode == 0, f"Release updater failed: {result.stderr}")
        updated = target.read_text(encoding="utf-8")
        check(updated.count(sha) == 2, "Release updater did not update tag and annotation")



def validate_ui_and_access_model() -> None:
    demo_static = ROOT / "workloads/demo-service/app/static"
    template_static = (
        ROOT / "software-templates/tusker-service/skeleton/service/src/static"
    )
    for root, label in (
        (demo_static, "Demo"),
        (template_static, "Generated-service"),
    ):
        for name in ("index.html", "styles.css", "app.js"):
            check((root / name).is_file(), f"{label} UI is missing {name}")

        html = (root / "index.html").read_text(encoding="utf-8")
        js = (root / "app.js").read_text(encoding="utf-8")
        check("/assets/styles.css" in html, f"{label} UI does not load local CSS")
        check("/assets/app.js" in html, f"{label} UI does not load local JavaScript")
        check("https://" not in html, f"{label} UI unexpectedly depends on external assets")
        check("innerHTML" not in js, f"{label} UI uses innerHTML for dynamic content")

    demo_main = (ROOT / "workloads/demo-service/app/main.py").read_text(
        encoding="utf-8"
    )
    template_main = (
        ROOT / "software-templates/tusker-service/skeleton/service/src/main.py"
    ).read_text(encoding="utf-8")
    for text, label in ((demo_main, "Demo"), (template_main, "Generated-service")):
        for marker in (
            'app.mount("/assets"',
            'Content-Security-Policy',
            '@app.get("/", include_in_schema=False)',
            '@app.get("/api/v1/status"',
        ):
            check(marker in text, f"{label} application is missing UI marker: {marker}")

    demo_application = load_yaml(
        ROOT / "gitops/applications/workloads/demo-service/application-development.yaml"
    )
    generated_application = load_yaml(
        ROOT
        / "software-templates/tusker-service/skeleton/gitops-registration/application.yaml"
    )
    for documents, label in (
        (demo_application, "Demo"),
        (generated_application, "Generated-service"),
    ):
        if not documents:
            continue
        labels = (
            documents[0]
            .get("spec", {})
            .get("syncPolicy", {})
            .get("managedNamespaceMetadata", {})
            .get("labels", {})
        )
        check(
            labels.get("platform.stonetusker.com/workload") == "true",
            f"{label} Application does not label its workload namespace",
        )

    demo_policy = (ROOT / "workloads/demo-service/base/network-policy.yaml").read_text(
        encoding="utf-8"
    )
    template_policy = (
        ROOT
        / "software-templates/tusker-service/skeleton/service/deploy/base/network-policy.yaml"
    ).read_text(encoding="utf-8")
    for text, label in ((demo_policy, "Demo"), (template_policy, "Generated-service")):
        check(
            "platform.stonetusker.com/workload" in text,
            f"{label} NetworkPolicy omits approved workload namespaces",
        )

    access_doc = ROOT / "docs/SERVICE-DEPLOYMENT-AND-ACCESS.md"
    check(access_doc.is_file(), "Service deployment and access guide is missing")
    if access_doc.is_file():
        text = access_doc.read_text(encoding="utf-8")
        for marker in (
            "demo-service-development",
            "<service-name>-development",
            "svc.cluster.local",
            "does not clone arbitrary",
            "scripts/demo/open-demo-ui.sh",
        ):
            check(marker in text, f"Service access guide is missing: {marker}")

    print("Browser UI and service-access validation: passed")

def validate_repository_hygiene() -> None:
    forbidden_files = []
    maintained_roots = [
        ROOT / "workloads/demo-service",
        ROOT / "software-templates/tusker-service",
        ROOT / "scripts/demo",
    ]
    forbidden_names = {".coverage", "coverage.xml", ".DS_Store"}
    forbidden_dirs = {"__pycache__", ".pytest_cache", ".mypy_cache", ".ruff_cache"}
    for maintained_root in maintained_roots:
        if not maintained_root.exists():
            continue
        for path in maintained_root.rglob("*"):
            if path.name in forbidden_names or (
                path.is_dir() and path.name in forbidden_dirs
            ) or path.suffix == ".pyc":
                forbidden_files.append(str(path.relative_to(ROOT)))
    check(
        not forbidden_files,
        "Generated test/cache artifacts are present in maintained source: "
        + ", ".join(forbidden_files[:20]),
    )

    check(
        not (ROOT / "workloads/demo-service/base/content").exists(),
        "Obsolete static NGINX demo content is still present; run scripts/demo/cleanup-demo-source.sh",
    )

    gitignore = ROOT / ".gitignore"
    check(gitignore.exists(), "Repository .gitignore is missing")
    if gitignore.exists():
        text = gitignore.read_text(encoding="utf-8")
        for marker in (".generated/", "node_modules/", ".venv/", "__pycache__/", "coverage.xml"):
            check(marker in text, f".gitignore is missing {marker}")
    print("Repository hygiene validation: passed")


def main() -> int:
    validate_yaml()
    validate_python()
    validate_kustomize_references()
    validate_openapi_and_docs()
    validate_workflows()
    validate_template_definition()
    validate_rendered_template()
    validate_live_app_tests()
    validate_release_updater()
    validate_ui_and_access_model()
    validate_repository_hygiene()

    if WARNINGS:
        print("\nVALIDATION WARNINGS", file=sys.stderr)
        for warning in WARNINGS:
            print(f"- {warning}", file=sys.stderr)

    if ERRORS:
        print("\nVALIDATION FAILED", file=sys.stderr)
        for error in ERRORS:
            print(f"- {error}", file=sys.stderr)
        return 1

    print(
        f"\nValidation passed: {CHECKS} structural checks plus "
        "application and public/private template tests"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
