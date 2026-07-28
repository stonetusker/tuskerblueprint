#!/usr/bin/env python3
from __future__ import annotations

import re
import subprocess
import sys
from pathlib import Path
from typing import Any

import yaml

ROOT = Path(__file__).resolve().parents[1]
SKIP_PARTS = {
    '.git',
    '.generated',
    '.venv',
    '.yarn',
    '__MACOSX',
    '__pycache__',
    '.pytest_cache',
    '.mypy_cache',
    '.ruff_cache',
    'build',
    'dist',
    'node_modules',
    'venv',
}
HYGIENE_TRAVERSAL_SKIP_PARTS = {
    '.git',
    '.generated',
    '.venv',
    '.yarn',
    'build',
    'dist',
    'node_modules',
    'venv',
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
                'while constructing a mapping',
                node.start_mark,
                f'duplicate key {key!r}',
                key_node.start_mark,
            )
        mapping[key] = loader.construct_object(value_node, deep=deep)
    return mapping


UniqueKeyLoader.add_constructor(
    yaml.resolver.BaseResolver.DEFAULT_MAPPING_TAG,
    _construct_mapping,
)


def files(pattern: str):
    for path in ROOT.rglob(pattern):
        if not any(part in SKIP_PARTS for part in path.parts):
            yield path


def load_yaml(path: Path) -> list[Any]:
    return list(
        yaml.load_all(
            path.read_text(encoding='utf-8'),
            Loader=UniqueKeyLoader,
        )
    )


def is_jinja_template(path: Path) -> bool:
    return '{%' in path.read_text(encoding='utf-8', errors='replace')


def validate_yaml() -> None:
    count = 0
    skipped_templates = 0
    for path in list(files('*.yaml')) + list(files('*.yml')):
        if is_jinja_template(path):
            skipped_templates += 1
            continue
        try:
            load_yaml(path)
        except Exception as exc:
            raise RuntimeError(f'Invalid YAML: {path.relative_to(ROOT)}: {exc}') from exc
        count += 1
    print(
        f'YAML parsed with duplicate-key protection: {count} files; '
        f'{skipped_templates} raw Jinja templates deferred to rendered validation'
    )


def validate_required_files() -> None:
    required = [
        'catalog-info.yaml',
        'mkdocs.yml',
        'catalog/components/backstage.yaml',
        'catalog/components/demo-service.yaml',
        'software-templates/tusker-service/template.yaml',
        'platform-services/backstage/values/development.yaml',
        'platform-services/backstage/values/development-idp.yaml',
        'platform-services/backstage/manifests/cluster-role.yaml',
        'gitops/applications/workloads/demo-service/application-development.yaml',
        'backstage-app/overrides/packages/backend/src/index.ts',
        'backstage-app/overrides/packages/app/src/components/catalog/EntityPage.tsx',
        'docs/IDP-MIGRATION-RUNBOOK.md',
    ]
    missing = [item for item in required if not (ROOT / item).is_file()]
    if missing:
        raise RuntimeError(f'Missing required files: {missing}')
    print(f'Required IDP files: {len(required)} present')


def validate_catalog_targets() -> None:
    root_catalog = load_yaml(ROOT / 'catalog-info.yaml')[0]
    targets = root_catalog.get('spec', {}).get('targets', [])
    missing = []
    for target in targets:
        path = (ROOT / target).resolve()
        if not path.is_file():
            missing.append(target)
    if missing:
        raise RuntimeError(f'Missing catalog targets: {missing}')
    print(f'Catalog targets: {len(targets)} present')



def validate_catalog_relations() -> None:
    entity_files = list((ROOT / 'catalog').rglob('*.yaml')) + [
        ROOT / 'software-templates/tusker-service/template.yaml'
    ]
    entities: dict[str, tuple[Path, dict[str, Any]]] = {}
    for path in entity_files:
        for document in load_yaml(path):
            if not isinstance(document, dict):
                continue
            kind = str(document.get('kind', '')).lower()
            metadata = document.get('metadata') or {}
            name = metadata.get('name') if isinstance(metadata, dict) else None
            namespace = (
                metadata.get('namespace', 'default')
                if isinstance(metadata, dict)
                else 'default'
            )
            if kind and name:
                entities[f'{kind}:{namespace}/{name}'] = (path, document)

    def normalize(reference: str, default_kind: str | None = None) -> str:
        if ':' in reference:
            kind, remainder = reference.split(':', 1)
        else:
            if default_kind is None:
                raise ValueError(f'Reference lacks a kind: {reference}')
            kind, remainder = default_kind, reference
        if '/' not in remainder:
            remainder = f'default/{remainder}'
        return f'{kind.lower()}:{remainder}'

    unresolved: list[str] = []
    for _, (path, document) in entities.items():
        spec = document.get('spec') or {}
        references: list[tuple[str, str | None]] = []
        if spec.get('owner'):
            references.append((spec['owner'], 'group'))
        if spec.get('system'):
            references.append((spec['system'], 'system'))
        if spec.get('domain'):
            references.append((spec['domain'], 'domain'))
        references.extend((item, 'api') for item in spec.get('providesApis', []) or [])
        references.extend((item, None) for item in spec.get('dependsOn', []) or [])
        for reference, default_kind in references:
            resolved = normalize(reference, default_kind)
            if resolved not in entities:
                unresolved.append(f'{path.relative_to(ROOT)}: {reference} -> {resolved}')
    if unresolved:
        raise RuntimeError('Unresolved catalog relations:\n' + '\n'.join(unresolved))
    print(f'Catalog relations: {len(entities)} entities resolved')



def validate_no_committed_secrets() -> None:
    patterns = [
        re.compile(r'-----BEGIN (?:RSA |EC |OPENSSH )?PRIVATE KEY-----'),
        re.compile(r'gh[pousr]_[A-Za-z0-9_]{20,}'),
        re.compile(
            r'(?i)(?:password|clientSecret|token):\s*["\']?'
            r'(?!\$\{|REPLACE_|<)[A-Za-z0-9+/=_-]{16,}'
        ),
    ]
    findings = []
    secret_manifests = []
    for path in files('*'):
        if not path.is_file() or path.suffix.lower() in {
            '.zip',
            '.png',
            '.jpg',
            '.jpeg',
            '.gif',
            '.pdf',
        }:
            continue
        try:
            text = path.read_text(encoding='utf-8')
        except UnicodeDecodeError:
            continue
        for pattern in patterns:
            if pattern.search(text):
                findings.append(str(path.relative_to(ROOT)))
                break
        if path.suffix in {'.yaml', '.yml'} and not is_jinja_template(path):
            for document in load_yaml(path):
                if isinstance(document, dict) and document.get('kind') == 'Secret':
                    secret_manifests.append(str(path.relative_to(ROOT)))
    if findings:
        raise RuntimeError(f'Potential committed secrets: {findings}')
    if secret_manifests:
        raise RuntimeError(f'Kubernetes Secret manifests must not be committed: {secret_manifests}')
    print('Secret-pattern and Kubernetes Secret-manifest checks: passed')


def validate_kustomize_references() -> None:
    checked = 0
    missing: list[str] = []
    for path in files('kustomization.yaml'):
        data = load_yaml(path)[0] or {}
        for item in data.get('resources', []) or []:
            if not isinstance(item, str) or item.startswith(('http://', 'https://')):
                continue
            target = (path.parent / item).resolve()
            if target.is_dir():
                if not (target / 'kustomization.yaml').is_file() and not (
                    target / 'kustomization.yml'
                ).is_file():
                    missing.append(f'{path.relative_to(ROOT)} -> {item} (directory has no kustomization)')
            elif not target.exists():
                missing.append(f'{path.relative_to(ROOT)} -> {item} (missing)')
        checked += 1
    if missing:
        raise RuntimeError('Invalid Kustomize references:\n' + '\n'.join(missing))
    print(f'Kustomize references: {checked} files checked')


def validate_kustomize_render() -> None:
    if (
        subprocess.run(
            ['bash', '-lc', 'command -v kubectl >/dev/null'],
            capture_output=True,
        ).returncode
        != 0
    ):
        print('kubectl not installed; skipped executable Kustomize render checks')
        return
    paths = [
        'gitops/environments/development',
        'platform-services/backstage/manifests',
        'workloads/demo-service/overlays/development',
    ]
    for item in paths:
        subprocess.run(
            ['kubectl', 'kustomize', str(ROOT / item)],
            check=True,
            stdout=subprocess.DEVNULL,
        )
    print(f'Kustomize rendered: {len(paths)} paths')


def validate_hygiene() -> None:
    """Reject committed artifacts without failing on ignored local build trees."""

    forbidden = []
    maintained_roots = [
        ROOT / 'workloads',
        ROOT / 'software-templates',
        ROOT / 'scripts',
        ROOT / 'catalog',
        ROOT / 'gitops',
        ROOT / 'platform-services',
    ]
    forbidden_dirs = {
        '__MACOSX',
        '__pycache__',
        '.pytest_cache',
        '.mypy_cache',
        '.ruff_cache',
    }
    forbidden_names = {'.DS_Store', '.coverage', 'coverage.xml'}

    for maintained_root in maintained_roots:
        if not maintained_root.exists():
            continue
        for path in maintained_root.rglob('*'):
            if any(
                part in HYGIENE_TRAVERSAL_SKIP_PARTS
                for part in path.relative_to(ROOT).parts
            ):
                continue
            if path.is_dir() and path.name in forbidden_dirs:
                forbidden.append(str(path.relative_to(ROOT)))
            elif path.is_file() and (path.name in forbidden_names or path.suffix == '.pyc'):
                forbidden.append(str(path.relative_to(ROOT)))

    if forbidden:
        raise RuntimeError(f'Forbidden generated files: {forbidden[:20]}')
    print('Repository hygiene: passed')


def main() -> int:
    validate_yaml()
    validate_required_files()
    validate_catalog_targets()
    validate_catalog_relations()
    validate_no_committed_secrets()
    validate_kustomize_references()
    validate_kustomize_render()
    validate_hygiene()
    print('TuskerBlueprint IDP validation passed')
    return 0


if __name__ == '__main__':
    try:
        raise SystemExit(main())
    except Exception as exc:
        print(f'ERROR: {exc}', file=sys.stderr)
        raise SystemExit(1)
