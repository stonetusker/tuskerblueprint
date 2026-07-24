# syntax=docker/dockerfile:1.7

#
# Dependency stage
#
# Native Node.js dependencies are built here. Compiler packages are not copied
# into the final runtime image.
#
FROM node:20-bookworm-slim AS dependencies

ENV NODE_ENV=production \
    NODE_OPTIONS=--no-node-snapshot \
    PYTHON=/usr/bin/python3 \
    npm_config_python=/usr/bin/python3 \
    npm_config_build_from_source=true \
    COREPACK_ENABLE_DOWNLOAD_PROMPT=0 \
    YARN_ENABLE_IMMUTABLE_INSTALLS=true \
    YARN_ENABLE_INLINE_BUILDS=1

USER root

RUN apt-get update && \
    apt-get install --yes --no-install-recommends \
      build-essential \
      ca-certificates \
      cmake \
      g++ \
      git \
      libsecret-1-dev \
      libsqlite3-dev \
      libssl-dev \
      make \
      ninja-build \
      pkg-config \
      python3 \
      python3-setuptools && \
    rm -rf /var/lib/apt/lists/*

RUN corepack enable

WORKDIR /app

COPY package.json yarn.lock backstage.json .yarnrc.yml ./
COPY .yarn/ ./.yarn/

COPY packages/backend/dist/skeleton.tar.gz ./

RUN tar xzf skeleton.tar.gz && \
    rm skeleton.tar.gz

#
# Build native modules here as root. YARN_ENABLE_INLINE_BUILDS ensures that
# compiler errors are printed directly in GitHub Actions and Docker logs.
#
RUN corepack yarn --version && \
    corepack yarn workspaces focus --all --production

#
# Runtime stage
#
FROM node:20-bookworm-slim AS runtime

ENV NODE_ENV=production \
    NODE_OPTIONS=--no-node-snapshot

USER root

RUN apt-get update && \
    apt-get install --yes --no-install-recommends \
      ca-certificates \
      libsecret-1-0 \
      libsqlite3-0 \
      libstdc++6 \
      tini && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY --from=dependencies /app /app

COPY packages/backend/dist/bundle.tar.gz ./
COPY app-config*.yaml ./

RUN tar xzf bundle.tar.gz && \
    rm bundle.tar.gz && \
    chown -R node:node /app

USER node

EXPOSE 7007

ENTRYPOINT ["/usr/bin/tini", "--"]

CMD ["node", "packages/backend", "--config", "app-config.yaml", "--config", "app-config.production.yaml"]
