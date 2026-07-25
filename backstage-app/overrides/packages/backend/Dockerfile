# syntax=docker/dockerfile:1.7

#
# Dependency build stage
#
FROM node:20-bookworm-slim AS dependencies

ENV NODE_ENV=production \
    NODE_OPTIONS=--no-node-snapshot \
    PYTHON=/usr/bin/python3 \
    npm_config_python=/usr/bin/python3 \
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

#
# Copy the Yarn configuration and workspace metadata.
#
COPY package.json yarn.lock backstage.json .yarnrc.yml ./
COPY .yarn/ ./.yarn/

#
# The Backstage backend build creates this archive. It contains the root and
# workspace package.json files required for the production dependency install.
#
COPY packages/backend/dist/skeleton.tar.gz ./

RUN tar xzf skeleton.tar.gz && \
    rm skeleton.tar.gz

#
# Install production dependencies.
#
# Do not set npm_config_build_from_source=true. Native packages should use
# compatible prebuilt binaries when available and compile only when required.
#
# node-gyp is provided by the root production dependency added during
# bootstrap-custom-app.sh.
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

