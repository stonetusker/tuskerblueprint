#!/usr/bin/env python3
"""Render and validate the Tusker service golden path without Backstage."""

from __future__ import annotations

from html.parser import HTMLParser
from pathlib import Path
import importlib.util
import os
import re
import shutil
import subprocess
import sys
import tempfile
from typing import Any

import yaml

ROOT = Path(__file__).resolve().parents[1]
SERVICE_SOURCE = ROOT / "software-templates/tusker-service/skeleton/service"
GITOPS_SOURCE = ROOT / "software-templates/tusker-service/skeleton/gitops-registration"

REPLACEMENTS = {
    "${{ values.name }}": "sample-service",
    "${{ values.description }}": "Sample customer notification service",
    "${{ values.owner }}": "group:default/developers",
    "${{ values.system }}": "system:default/tuskerblueprint",
    "${{ values.developerUsername }}": "subeeshlearn",
    "${{ values.port }}": "8000",
    "${{ values.repoUrl | parseRepoUrl | pick('owner') }}": "stonetusker",
    "${{ values.repoUrl | parseRepoUrl | pick('repo') }}": "sample-service",
}


class UniqueKeyLoader(yaml.SafeLoader):
    """YAML loader that rejects duplicate keys."""


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


def render_tree(source: Path, destination: Path, visibility: str) -> None:
    shutil.copytree(source, destination)
    for path in destination.rglob("*"):
        if not path.is_file():
            continue
        try:
            content = path.read_text(encoding="utf-8")
        except UnicodeDecodeError:
            continue
        for source_value, rendered_value in REPLACEMENTS.items():
            content = content.replace(source_value, rendered_value)
        content = content.replace("${{ values.repoVisibility }}", visibility)
        # Backstage escaping that preserves GitHub expressions in generated YAML.
        content = re.sub(
            r"\$\{\{ '\$\{\{ (.*?) \}\}' \}\}",
            lambda match: "${{ " + match.group(1) + " }}",
            content,
        )
        path.write_text(content, encoding="utf-8")


def assert_no_unresolved_template_values(root: Path) -> None:
    for path in root.rglob("*"):
        if not path.is_file():
            continue
        try:
            content = path.read_text(encoding="utf-8")
        except UnicodeDecodeError:
            continue
        assert "${{ values." not in content, f"unrendered value in {path}"
        assert "{%" not in content, f"unrendered control block in {path}"


def parse_yaml_tree(root: Path) -> None:
    for path in sorted(root.rglob("*.yaml")) + sorted(root.rglob("*.yml")):
        list(yaml.load_all(path.read_text(encoding="utf-8"), Loader=UniqueKeyLoader))


def validate_python_syntax(root: Path) -> None:
    for path in root.rglob("*.py"):
        compile(path.read_text(encoding="utf-8"), str(path), "exec")


def validate_html(root: Path) -> None:
    parser = HTMLParser()
    for path in root.rglob("*.html"):
        parser.feed(path.read_text(encoding="utf-8"))
        parser.close()


def validate_shell(root: Path) -> None:
    for path in root.rglob("*.sh"):
        subprocess.run(["bash", "-n", str(path)], check=True)


def run_python_module(
    module: str,
    arguments: list[str],
    *,
    cwd: Path,
    required_in_ci: bool = True,
) -> None:
    if importlib.util.find_spec(module) is None:
        if required_in_ci and os.environ.get("TUSKER_STRICT_TEMPLATE_VALIDATION", "").lower() == "true":
            raise RuntimeError(
                f"required validation module {module!r} is not installed"
            )
        print(
            f"Skipping optional local {module} validation; install the golden-path "
            "requirements-dev.txt to run the complete gate."
        )
        return
    subprocess.run(
        [sys.executable, "-m", module, *arguments],
        cwd=cwd,
        check=True,
    )


for visibility in ("private", "public"):
    with tempfile.TemporaryDirectory() as directory:
        workspace = Path(directory)
        service = workspace / f"sample-service-{visibility}"
        gitops = workspace / f"gitops-registration-{visibility}"
        render_tree(SERVICE_SOURCE, service, visibility)
        render_tree(GITOPS_SOURCE, gitops, visibility)

        assert_no_unresolved_template_values(service)
        assert_no_unresolved_template_values(gitops)
        parse_yaml_tree(service)
        parse_yaml_tree(gitops)
        validate_python_syntax(service)
        validate_html(service)
        validate_shell(service)

        workflow = (service / ".github/workflows/ci.yml").read_text(encoding="utf-8")
        assert "${{ github.sha }}" in workflow
        assert "verify-public-package" not in workflow
        assert "upload-sarif" not in workflow

        service_account = (service / "deploy/base/service-account.yaml").read_text(encoding="utf-8")
        assert "name: ghcr-pull-secret" in service_account
        external_secret = (service / "deploy/base/external-secret.yaml").read_text(encoding="utf-8")
        assert "kind: ExternalSecret" in external_secret
        assert "kubernetes-platform-secrets" in external_secret

        application = yaml.load(
            (gitops / "application.yaml").read_text(encoding="utf-8"),
            Loader=UniqueKeyLoader,
        )
        assert application["metadata"]["name"] == "sample-service-development"
        assert application["spec"]["source"]["repoURL"] == (
            "https://github.com/stonetusker/sample-service.git"
        )
        assert application["spec"]["source"]["path"] == "deploy/overlays/development"
        assert application["spec"]["destination"]["namespace"] == (
            "sample-service-development"
        )

        subprocess.run(
            [sys.executable, "scripts/validate_repository.py"],
            cwd=service,
            check=True,
        )
        run_python_module(
            "ruff", ["format", "--check", "app", "tests"], cwd=service
        )
        run_python_module("ruff", ["check", "app", "tests"], cwd=service)
        run_python_module("mypy", ["app"], cwd=service)
        run_python_module(
            "pytest",
            [
                "--cov=app",
                "--cov-branch",
                "--cov-report=term-missing",
                "--cov-fail-under=85",
            ],
            cwd=service,
        )

print("Template render validation passed for private and public repositories")
