FROM python:3.12-slim-bookworm

ARG VCS_REF=development
ARG BUILD_DATE=unknown

LABEL org.opencontainers.image.title="StoneTusker Customer Notification API" \
      org.opencontainers.image.description="Reference workload for the StoneTusker delivery-platform demo" \
      org.opencontainers.image.source="https://github.com/stonetusker/tuskerblueprint" \
      org.opencontainers.image.revision="${VCS_REF}" \
      org.opencontainers.image.created="${BUILD_DATE}"

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PYTHONPYCACHEPREFIX=/tmp/pycache \
    HOME=/tmp \
    SERVICE_NAME=demo-service \
    APP_ENV=container \
    APP_VERSION=${VCS_REF} \
    DEMO_FAILURE_MODE=none \
    FAILURE_DELAY_MS=2500

RUN groupadd --gid 10001 app && \
    useradd --uid 10001 --gid app --no-create-home --shell /usr/sbin/nologin app

WORKDIR /app
COPY requirements.txt ./
RUN pip install --no-cache-dir --disable-pip-version-check -r requirements.txt

COPY app ./app

USER 10001:10001
EXPOSE 8000

HEALTHCHECK --interval=30s --timeout=3s --start-period=10s --retries=3 \
  CMD python -c "import urllib.request; urllib.request.urlopen('http://127.0.0.1:8000/healthz', timeout=2)"

CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000", "--no-access-log"]
