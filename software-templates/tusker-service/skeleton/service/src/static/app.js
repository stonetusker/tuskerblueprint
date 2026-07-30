"use strict";

const byId = (id) => document.getElementById(id);

function setText(id, value) {
  const element = byId(id);
  if (element) {
    element.textContent = value;
  }
}

function shortVersion(version) {
  return version && version.length > 16 ? `${version.slice(0, 12)}…` : version;
}

async function loadStatus() {
  try {
    const [metadataResponse, readinessResponse] = await Promise.all([
      fetch("/api/v1/status"),
      fetch("/readyz"),
    ]);
    const metadata = await metadataResponse.json();
    if (!metadataResponse.ok) {
      throw new Error(`Status request failed with HTTP ${metadataResponse.status}`);
    }

    setText("service-name", metadata.service);
    setText("api-status", metadata.status === "ok" ? "Operational" : metadata.status);
    setText("readiness-status", readinessResponse.ok ? "Ready" : "Unavailable");
    setText("release-version", shortVersion(metadata.version));
    setText("release-environment", metadata.environment);
    setText("correlation-id", metadataResponse.headers.get("X-Correlation-ID") || "Generated");
    byId("release-dot")?.classList.toggle("online", readinessResponse.ok);
  } catch (error) {
    setText("api-status", "Unavailable");
    setText("readiness-status", "Unavailable");
    setText("release-version", "Connection failed");
    setText("release-environment", error.message);
  }
}

async function runExample() {
  const button = byId("example-button");
  const result = byId("example-result");
  button.disabled = true;
  result.textContent = "Calling /api/v1/example...";

  try {
    const response = await fetch("/api/v1/example", {
      headers: { "X-Correlation-ID": `ui-${Date.now()}` },
    });
    const payload = await response.json();
    if (!response.ok) {
      throw new Error(payload.detail || `Request failed with HTTP ${response.status}`);
    }
    const correlation = response.headers.get("X-Correlation-ID") || "not returned";
    setText("correlation-id", correlation);
    result.textContent = JSON.stringify({ ...payload, correlation_id: correlation }, null, 2);
  } catch (error) {
    result.textContent = error.message;
  } finally {
    button.disabled = false;
  }
}

byId("example-button")?.addEventListener("click", runExample);
void loadStatus();
