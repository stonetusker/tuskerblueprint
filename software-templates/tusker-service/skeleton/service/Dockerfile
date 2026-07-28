FROM python:3.12-slim-bookworm

ARG VCS_REF=development
ARG BUILD_DATE=unknown

LABEL org.opencontainers.image.title="${{ values.name }}" \
      org.opencontainers.image.description="${{ values.description }}" \
      org.opencontainers.image.source="https://github.com/${{ values.repoUrl | parseRepoUrl | pick('owner') }}/${{ values.repoUrl | parseRepoUrl | pick('repo') }}" \
      org.opencontainers.image.revision="${VCS_REF}" \
      org.opencontainers.image.created="${BUILD_DATE}"

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PYTHONPYCACHEPREFIX=/tmp/pycache \
    HOME=/tmp \
    SERVICE_NAME=${{ values.name }} \
    APP_ENV=container \
    APP_VERSION=${VCS_REF} \
    DEMO_FAILURE_MODE=none

RUN groupadd --gid 10001 app && \
    useradd --uid 10001 --gid app --no-create-home --shell /usr/sbin/nologin app

WORKDIR /app
COPY requirements.txt ./
RUN pip install --no-cache-dir --disable-pip-version-check -r requirements.txt
COPY src ./src

USER 10001:10001
EXPOSE ${{ values.port }}
HEALTHCHECK --interval=30s --timeout=3s --start-period=10s --retries=3 \
  CMD python -c "import urllib.request; urllib.request.urlopen('http://127.0.0.1:${{ values.port }}/healthz', timeout=2)"
CMD ["uvicorn", "src.main:app", "--host", "0.0.0.0", "--port", "${{ values.port }}", "--no-access-log"]
