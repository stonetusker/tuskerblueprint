#!/usr/bin/env python3
"""Validate the provisioned development observability experience."""

from __future__ import annotations

import json
from pathlib import Path
from typing import Any

import yaml
from promql_parser import parse

ROOT = Path(__file__).resolve().parents[1]
DASHBOARD_PATH = (
    ROOT
    / "platform-services/grafana/dashboards/development/demo-service-delivery.json"
)
GRAFANA_VALUES_PATH = ROOT / "platform-services/grafana/values/development.yaml"
PROMETHEUS_VALUES_PATH = ROOT / "platform-services/prometheus/values/development.yaml"
LOKI_VALUES_PATH = ROOT / "platform-services/loki/values/development.yaml"
OBSERVABILITY_KUSTOMIZATION_PATH = (
    ROOT / "gitops/applications/platform/observability/kustomization.yaml"
)
ALLOY_CONFIG_MAP_PATH = ROOT / "platform-services/alloy/config-map.yaml"


def load_yaml(path: Path) -> dict[str, Any]:
    document = yaml.safe_load(path.read_text(encoding="utf-8"))
    if not isinstance(document, dict):
        raise TypeError(f"Expected a YAML object in {path.relative_to(ROOT)}")
    return document


def expanded_promql(expression: str) -> str:
    return (
        expression.replace("$service", "demo-service")
        .replace("$environment", "development")
        .replace("$namespace", "demo-service-development")
        .replace("$__rate_interval", "1m")
        .replace("$__range", "30m")
    )


def validate_dashboard() -> None:
    dashboard = json.loads(DASHBOARD_PATH.read_text(encoding="utf-8"))
    if dashboard.get("uid") != "stonetusker-demo-service":
        raise ValueError("The stable dashboard UID changed")

    panels = dashboard.get("panels")
    if not isinstance(panels, list) or not panels:
        raise ValueError("The dashboard has no panels")

    panel_ids: set[int] = set()
    prometheus_queries = 0
    for panel in panels:
        panel_id = panel["id"]
        if panel_id in panel_ids:
            raise ValueError(f"Duplicate dashboard panel ID: {panel_id}")
        panel_ids.add(panel_id)

        grid = panel["gridPos"]
        if grid["x"] < 0 or grid["w"] <= 0 or grid["x"] + grid["w"] > 24:
            raise ValueError(f"Panel {panel_id} exceeds the 24-column dashboard grid")

        datasource_type = (panel.get("datasource") or {}).get("type")
        if datasource_type != "prometheus":
            continue

        for target in panel.get("targets", []):
            expression = target.get("expr")
            if not expression:
                continue
            parse(expanded_promql(expression))
            prometheus_queries += 1

            if "rate(" in expression and "$__rate_interval" not in expression:
                raise ValueError(
                    f"Panel {panel_id} uses rate() without $__rate_interval"
                )

    if prometheus_queries < 15:
        raise ValueError("Expected at least 15 Prometheus dashboard queries")

    log_queries = [
        target["expr"]
        for panel in panels
        if (panel.get("datasource") or {}).get("type") == "loki"
        for target in panel.get("targets", [])
        if target.get("expr")
    ]
    expected_selector = (
        '{namespace="$namespace", app="$service", container="app"} | json'
    )
    if expected_selector not in log_queries:
        raise ValueError("The dashboard does not contain the expected Loki query")


def validate_collection_contract() -> None:
    grafana_values = load_yaml(GRAFANA_VALUES_PATH)
    prometheus_values = load_yaml(PROMETHEUS_VALUES_PATH)
    loki_values = load_yaml(LOKI_VALUES_PATH)

    prometheus_interval = prometheus_values["server"]["global"]["scrape_interval"]
    grafana_interval = grafana_values["datasources"]["datasources.yaml"][
        "datasources"
    ][0]["jsonData"]["timeInterval"]
    if prometheus_interval != grafana_interval:
        raise ValueError(
            "Grafana datasource timeInterval must match Prometheus scrape_interval"
        )

    if grafana_values.get("dashboardsConfigMaps", {}).get("default") != (
        "grafana-dashboard-demo-service"
    ):
        raise ValueError("Grafana is not mounting the demo dashboard ConfigMap")

    if loki_values["loki"]["commonConfig"]["replication_factor"] != 1:
        raise ValueError("Single-binary Loki must use replication_factor: 1")

    observability = load_yaml(OBSERVABILITY_KUSTOMIZATION_PATH)
    if "alloy" not in observability.get("resources", []):
        raise ValueError("Alloy is not enabled in the observability Kustomization")

    alloy_config_map = load_yaml(ALLOY_CONFIG_MAP_PATH)
    alloy_config = alloy_config_map["data"]["config.alloy"]
    required_fragments = (
        'field = "spec.nodeName=" + sys.env("NODE_NAME")',
        'replacement   = "/var/log/pods/*$1/*.log"',
        "stage.cri {}",
        "forward_to = [loki.process.pod_logs.receiver]",
    )
    for fragment in required_fragments:
        if fragment not in alloy_config:
            raise ValueError(f"Alloy collection contract is missing: {fragment}")


def main() -> None:
    validate_dashboard()
    validate_collection_contract()
    print("Observability configuration validation passed")


if __name__ == "__main__":
    main()
