# Architecture

A single hardened FastAPI container serves the browser UI, REST API, health endpoints and Prometheus metrics. Static assets are bundled in the image, so the demo has no CDN or separate frontend dependency.

Argo CD reads `deploy/overlays/development` from this repository and deploys into `${{ values.name }}-development`.
