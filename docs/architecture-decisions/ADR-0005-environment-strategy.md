# ADR-0005 – Environment Strategy

## Status

Accepted

## Context

Development, staging, and production environments require independent configuration while maintaining a consistent deployment model.

## Decision

Each environment maintains its own Argo CD Application definition.

Environment-specific configuration is stored under:

```text
platform-services/<service>/values/
```

Each environment references its corresponding values file.

## Consequences

* Explicit environment configuration.
* Simple promotion workflow.
* Reduced deployment risk.
* Improved operational clarity.

