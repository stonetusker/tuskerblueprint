# Implementation guide

Implement platform capabilities in `tuskerblueprint` and application capabilities in individual service repositories. Do not add maintained application source beneath the platform repository. Reusable application defaults belong in `software-templates/tusker-service/skeleton/service`.

Changes to the golden path must update its source, tests, workflows, TechDocs, OpenAPI and Kubernetes overlays together and must pass `make validate`.
