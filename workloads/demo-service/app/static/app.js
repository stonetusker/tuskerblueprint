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

function correlationId() {
  if (globalThis.crypto && typeof globalThis.crypto.randomUUID === "function") {
    return `ui-${globalThis.crypto.randomUUID()}`;
  }
  return `ui-${Date.now()}`;
}

async function requestJson(url, options = {}) {
  const response = await fetch(url, options);
  const payload = await response.json().catch(() => ({}));
  if (!response.ok) {
    throw new Error(payload.detail || `Request failed with HTTP ${response.status}`);
  }
  return { response, payload };
}

async function loadStatus() {
  try {
    const [{ payload: metadata }, readinessResponse] = await Promise.all([
      requestJson("/api/v1/status"),
      fetch("/readyz"),
    ]);

    setText("service-name", metadata.service);
    setText("api-status", metadata.status === "ok" ? "Operational" : metadata.status);
    setText("readiness-status", readinessResponse.ok ? "Ready" : "Unavailable");
    setText("release-version", shortVersion(metadata.version));
    setText("release-environment", metadata.environment);
    byId("release-dot")?.classList.toggle("online", readinessResponse.ok);
  } catch (error) {
    setText("api-status", "Unavailable");
    setText("readiness-status", "Unavailable");
    setText("release-version", "Connection failed");
    setText("release-environment", error.message);
  }
}

function notificationItem(record) {
  const item = document.createElement("li");
  item.className = "notification-item";

  const channel = document.createElement("span");
  channel.className = "channel-icon";
  channel.textContent = record.channel.slice(0, 2);

  const content = document.createElement("div");
  content.className = "notification-content";

  const recipient = document.createElement("strong");
  recipient.textContent = record.recipient;

  const message = document.createElement("span");
  message.className = "notification-message";
  message.textContent = record.message;

  const metadata = document.createElement("span");
  metadata.className = "notification-meta";
  const accepted = new Date(record.accepted_at).toLocaleString();
  metadata.textContent = `${accepted} · ${record.state} · ${record.correlation_id}`;

  content.append(recipient, message, metadata);
  item.append(channel, content);
  return item;
}

async function loadNotifications() {
  const list = byId("notification-list");
  const empty = byId("notifications-empty");
  if (!list || !empty) {
    return;
  }

  try {
    const { payload } = await requestJson("/api/v1/notifications?limit=8");
    list.replaceChildren(...payload.map(notificationItem));
    empty.hidden = payload.length > 0;
  } catch (error) {
    list.replaceChildren();
    empty.hidden = false;
    empty.textContent = `Unable to load notifications: ${error.message}`;
  }
}

async function submitNotification(event) {
  event.preventDefault();

  const form = event.currentTarget;
  const button = byId("submit-button");
  const result = byId("form-result");
  const requestId = correlationId();
  const formData = new FormData(form);
  const payload = {
    channel: formData.get("channel"),
    recipient: formData.get("recipient"),
    message: formData.get("message"),
  };

  button.disabled = true;
  result.classList.remove("error");
  result.textContent = "Submitting request...";

  try {
    const { response, payload: record } = await requestJson("/api/v1/notifications", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "X-Correlation-ID": requestId,
        "X-Demo-Request": "browser-ui",
      },
      body: JSON.stringify(payload),
    });

    const returnedCorrelation = response.headers.get("X-Correlation-ID") || record.correlation_id;
    setText("latest-correlation", returnedCorrelation);
    result.textContent = `Accepted as ${record.id}. Use correlation ID ${returnedCorrelation} in Loki.`;
    await loadNotifications();
  } catch (error) {
    result.classList.add("error");
    result.textContent = error.message;
  } finally {
    button.disabled = false;
  }
}

byId("notification-form")?.addEventListener("submit", submitNotification);
byId("refresh-button")?.addEventListener("click", loadNotifications);

void Promise.all([loadStatus(), loadNotifications()]);
