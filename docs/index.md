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

## Primary personas

- **Developer:** creates and operates a service through approved templates.
- **Platform engineer:** owns templates, platform services, policy, and reliability.
- **Security engineer:** reviews guardrails, secret handling, and supply-chain controls.
- **Customer or stakeholder:** evaluates the operating model and reference architecture.

## Start here

1. Read [Architecture](architecture.md).
2. Walk through the [Developer journey](developer-journey.md).
3. Review the [Service standards](service-standards.md).
4. Follow the [Customer demo](demo-runbook.md).
