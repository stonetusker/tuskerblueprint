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

    const ready = readinessResponse.ok;
    setText("service-name", metadata.service);
    setText("api-status", metadata.status === "ok" ? "Operational" : metadata.status);
    setText("readiness-status", ready ? "Ready" : "Unavailable");
    setText("release-version", shortVersion(metadata.version));
    setText("release-environment", metadata.environment);
    setText("health-label", ready ? "Healthy" : "Attention");
    byId("release-dot")?.classList.toggle("online", ready);
  } catch (error) {
    setText("api-status", "Unavailable");
    setText("readiness-status", "Unavailable");
    setText("release-version", "Connection failed");
    setText("release-environment", "unknown");
    setText("health-label", "Unavailable");
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

function updateChannelMix(records) {
  const counts = { email: 0, sms: 0, webhook: 0 };
  for (const record of records) {
    if (Object.hasOwn(counts, record.channel)) {
      counts[record.channel] += 1;
    }
  }

  const total = records.length;
  setText("notification-total", String(total));

  for (const [channel, count] of Object.entries(counts)) {
    setText(`${channel}-count`, String(count));
    const width = total === 0 ? 0 : Math.max((count / total) * 100, count > 0 ? 8 : 0);
    const bar = byId(`${channel}-bar`);
    if (bar) {
      bar.style.width = `${width}%`;
    }
  }
}

async function loadNotifications() {
  const list = byId("notification-list");
  const empty = byId("notifications-empty");
  if (!list || !empty) {
    return;
  }

  try {
    const { payload } = await requestJson("/api/v1/notifications?limit=20");
    list.replaceChildren(...payload.map(notificationItem));
    empty.hidden = payload.length > 0;
    updateChannelMix(payload);
  } catch (error) {
    list.replaceChildren();
    empty.hidden = false;
    empty.replaceChildren();

    const title = document.createElement("strong");
    title.textContent = "Unable to load activity";
    const detail = document.createElement("p");
    detail.textContent = error.message;
    empty.append(title, detail);
    updateChannelMix([]);
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
  result.textContent = "Submitting through the platform API...";

  try {
    const { response, payload: record } = await requestJson("/api/v1/notifications", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "X-Correlation-ID": requestId,
        "X-Demo-Request": "executive-browser-ui",
      },
      body: JSON.stringify(payload),
    });

    const returnedCorrelation = response.headers.get("X-Correlation-ID") || record.correlation_id;
    setText("latest-correlation", returnedCorrelation);
    result.textContent = `Accepted. Correlation ID ${returnedCorrelation} can now be found in the application logs and Loki.`;
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
