# TuskerBlueprint custom Backstage application

This directory contains a reproducible bootstrap overlay for the plugin-enabled IDP image. It intentionally does not commit `node_modules` or a generated application tree.

## Why an overlay

Backstage publishes many independently versioned packages. The safe method is to create an official application skeleton, align its package versions to one Backstage release, install the selected plugins, and commit the resulting lockfile after validation.

## Generate locally

From the repository root:

```bash
scripts/backstage/bootstrap-custom-app.sh
cd .generated/backstage
corepack enable
yarn install --immutable
yarn tsc
yarn test --ci
yarn build:backend
```

The script overlays:

- GitHub sign-in
- Catalog, Scaffolder, Search, TechDocs, and API documentation
- Kubernetes entity content
- GitHub Actions entity content
- Argo CD entity card
- Modern Backstage backend modules

After a successful build, the GitHub workflow publishes `ghcr.io/stonetusker/tuskerblueprint-backstage`.

## Version control recommendation

For a long-lived production repository, run the bootstrap once, review the generated application, move it into a dedicated source repository or commit it under `backstage-app/runtime/`, and commit the generated `yarn.lock`. The workflow in this reference repository is optimized for a portfolio demonstration and explicit migration.
