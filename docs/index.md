# TuskerBlueprint Internal Developer Platform

TuskerBlueprint is a portfolio-grade Internal Developer Platform reference implementation. It combines Backstage, Argo CD, Kubernetes, GitHub, policy controls, and observability into one developer experience.

## What the platform demonstrates

- A searchable software catalog with explicit ownership and lifecycle metadata.
- Golden-path service creation through Backstage Software Templates.
- GitOps deployment and drift correction through Argo CD.
- Runtime visibility through the Backstage Kubernetes plugin.
- Deployment visibility through the Backstage Argo CD plugin.
- API discovery through OpenAPI entities.
- Documentation-as-code through TechDocs.
- Read-only platform access from the developer portal.
- Secret separation between GitHub, Backstage, and Argo CD.
- Explicit trust of the internal Argo CD server certificate.

## Primary personas

- **Developer:** creates and operates a service through approved templates.
- **Platform engineer:** owns templates, platform services, policy, and reliability.
- **Security engineer:** reviews guardrails, secret handling, and supply-chain controls.
- **Customer or stakeholder:** evaluates the operating model and reference architecture.

## Start here

1. Build the environment with [Setup from scratch](SETUP-FROM-SCRATCH.md).
2. Understand the platform through [Architecture](architecture.md).
3. Configure and operate [Backstage and Argo CD integration](BACKSTAGE-ARGOCD-INTEGRATION.md).
4. Walk through the [Developer journey](developer-journey.md).
5. Review the [Service standards](service-standards.md).
6. Follow the [Customer demo](demo-runbook.md).

## Local browser access

```text
Backstage: http://localhost:7007
Argo CD:   https://localhost:8080
```

Use separate port-forward sessions as documented in the setup guide.
