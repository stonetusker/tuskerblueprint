FROM node:20-bookworm-slim

ENV NODE_ENV=production
ENV PYTHON=/usr/bin/python3
ENV npm_config_python=/usr/bin/python3
ENV COREPACK_ENABLE_DOWNLOAD_PROMPT=0
ENV YARN_ENABLE_IMMUTABLE_INSTALLS=true

RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt-get update && \
    apt-get install --yes --no-install-recommends \
      python3 \
      make \
      g++ \
      build-essential \
      pkg-config \
      libsecret-1-dev \
      libsqlite3-dev && \
    rm -rf /var/lib/apt/lists/*

RUN corepack enable

USER node

WORKDIR /app

COPY --chown=node:node .yarn/ ./.yarn/
COPY --chown=node:node .yarnrc.yml ./
COPY --chown=node:node package.json yarn.lock backstage.json ./

COPY --chown=node:node packages/backend/dist/skeleton.tar.gz ./

RUN tar xzf skeleton.tar.gz && \
    rm skeleton.tar.gz

RUN --mount=type=cache,target=/home/node/.cache/yarn,sharing=locked,uid=1000,gid=1000 \
    corepack yarn workspaces focus --all --production && \
    corepack yarn cache clean

COPY --chown=node:node packages/backend/dist/bundle.tar.gz ./
COPY --chown=node:node app-config*.yaml ./

RUN tar xzf bundle.tar.gz && \
    rm bundle.tar.gz

EXPOSE 7007

CMD ["node", "packages/backend", "--config", "app-config.yaml", "--config", "app-config.production.yaml"]
