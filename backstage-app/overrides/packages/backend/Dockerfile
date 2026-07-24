# syntax=docker/dockerfile:1.7

#
# Stage 1: Install production dependencies and compile native modules.
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
      g++ \
      make \
      pkg-config \
      python3 \
      libsecret-1-dev \
      libsqlite3-dev && \
    rm -rf /var/lib/apt/lists/*

#
# Prepare the exact Yarn version used by the generated Backstage project.
# Running this as root avoids Corepack cache permission errors.
#
RUN corepack enable && \
    corepack prepare yarn@4.13.0 --activate && \
    yarn --version

WORKDIR /app

#
# Copy Yarn and workspace metadata first so Docker can cache the dependency
# installation layer independently of application source changes.
#
COPY package.json yarn.lock backstage.json .yarnrc.yml ./
COPY .yarn/ ./.yarn/

#
# The Backstage backend build creates skeleton.tar.gz containing the
# package.json files required for a production dependency installation.
#
COPY packages/backend/dist/skeleton.tar.gz ./

RUN tar xzf skeleton.tar.gz && \
    rm skeleton.tar.gz

#
# Install only production dependencies.
# Native modules such as better-sqlite3 are compiled here with the required
# Debian build toolchain.
#
RUN yarn workspaces focus --all --production

#
# Stage 2: Minimal runtime image.
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
      tini && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

#
# Copy the production dependency tree from the build stage.
#
COPY --from=dependencies /app /app

#
# Copy the compiled Backstage backend bundle and configuration.
#
COPY packages/backend/dist/bundle.tar.gz ./
COPY app-config*.yaml ./

RUN tar xzf bundle.tar.gz && \
    rm bundle.tar.gz && \
    chown -R node:node /app

USER node

EXPOSE 7007

ENTRYPOINT ["/usr/bin/tini", "--"]

CMD ["node", "packages/backend", "--config", "app-config.yaml", "--config", "app-config.production.yaml"]