# TuskerBlueprint Repository File-by-File Learning Guide


This guide explains what every file in the repository contains, why it exists, and what to learn from it. It is written for engineers studying Argo CD, Backstage, Kubernetes platform engineering, GitOps, infrastructure automation, policy-as-code, observability, CI/CD, and specification-driven development.


## How the repository works as a system

1. `specs/` defines the approved requirements and acceptance criteria.
2. `infrastructure/terraform/` establishes provider and version boundaries for infrastructure provisioning.
3. `infrastructure/ansible/` prepares the host, installs Kubernetes and Argo CD, and creates the minimum GitOps trust anchor.
4. `gitops/bootstrap/` establishes the root AppProject and environment root Application.
5. `gitops/environments/` composes the exact projects and applications belonging to development, staging, or production.
6. `gitops/applications/` tells Argo CD how to deploy every platform capability and sample workload.
7. `platform-services/` supplies environment-specific Helm values and policies.
8. `workloads/demo-service/` provides the customer-facing workload, Backstage entity, and TechDocs content.
9. `scripts/ci/` validates source; `scripts/platform-verification/` validates the running platform; `scripts/demo/` makes the live presentation deterministic.
10. `.github/workflows/` executes these controls for pull requests, main-branch changes, security checks, and releases.

## Recommended learning order

Start with `README.md`, `docs/ARCHITECTURE.md`, and the ADRs. Then study `specs/TRACEABILITY.md`, the bootstrap/root Application flow, AppProjects, one complete service such as Traefik, and the `demo-service` base plus overlays. Finish with CI checks, the runtime verification framework, and the demo runbook.

## File-by-file reference

## `Repository root`

Repository-wide metadata, contributor guidance, documentation entry points, local commands, catalog registration, and tool configuration.

- **`.editorconfig`**
  - **Contains:** EditorConfig rules for consistent character encoding, line endings, indentation, trailing whitespace, and final newlines across editors.
  - **Learn from it:** Learn the repository-wide engineering convention represented by this file.

- **`.gitattributes`**
  - **Contains:** Git attribute rules that normalize text files and line endings and can control generated/binary treatment.
  - **Learn from it:** Learn the repository-wide engineering convention represented by this file.

- **`.gitignore`**
  - **Contains:** Ignore patterns for local secrets, virtual environments, caches, Terraform state, release output, operating-system metadata, and other generated artifacts.
  - **Learn from it:** Learn the repository-wide engineering convention represented by this file.

- **`.gitleaks.toml`**
  - **Contains:** Gitleaks configuration and allow-list rules used to scan the repository for committed secrets.
  - **Learn from it:** Learn the repository-wide engineering convention represented by this file.

- **`.markdownlint.json`**
  - **Contains:** Markdownlint rule configuration establishing the documentation style enforced by contributors and CI.
  - **Learn from it:** Learn the repository-wide engineering convention represented by this file.

- **`.pre-commit-config.yaml`**
  - **Contains:** Pre-commit hook configuration that runs formatting, syntax, policy, and secret checks before commits are created.
  - **Learn from it:** Learn the repository-wide engineering convention represented by this file.

- **`.yamllint.yml`**
  - **Contains:** Yamllint rules for readable, portable YAML formatting.
  - **Learn from it:** Learn the repository-wide engineering convention represented by this file.

- **`CHANGELOG.md`**
  - **Contains:** Documentation titled **Changelog**. All notable changes to TuskerBlueprint are documented here. The project follows [Semantic Versioning](https://semver.org/) for public reference releases. Main sections include `[1.0.0] - 2026-07-20`, `Added`, `Changed`, `Security`.
  - **Learn from it:** Learn the repository-wide engineering convention represented by this file.

- **`CODE_OF_CONDUCT.md`**
  - **Contains:** Documentation titled **Code of Conduct**. Contributors must communicate professionally, review ideas on technical merit, and respect different backgrounds and levels of experience. Harassment, discrimination, personal attacks, deliberate disclosure of private information, and unsafe handling of customer or credential data are not accepted.
  - **Learn from it:** Learn the repository-wide engineering convention represented by this file.

- **`CONTRIBUTING.md`**
  - **Contains:** Documentation titled **Contributing**. TuskerBlueprint is maintained as a customer-facing reference implementation. Changes must improve correctness, clarity, security, repeatability, or demo value. Main sections include `Workflow`, `Required engineering rules`, `Commit convention`, `Review expectations`.
  - **Learn from it:** Learn the repository-wide engineering convention represented by this file.

- **`LICENSE`**
  - **Contains:** Apache License 2.0 legal terms governing use, modification, distribution, patent rights, notices, and warranty limitations.
  - **Learn from it:** Learn the repository-wide engineering convention represented by this file.

- **`Makefile`**
  - **Contains:** Make command interface for developers. Targets include `help` (Show available targets), `validate` (Run deterministic repository validation), `lint` (Alias for local lint and policy checks), `security` (Scan for committed secrets and unsafe repository content), `yaml` (Parse YAML and reject duplicate mapping keys), `shell` (Validate shell syntax and run ShellCheck when available), `kustomize` (Validate Kustomize references, duplicates, and optional rendering), `markdown` (Validate repository-relative Markdown links), `terraform` (Format-check and validate Terraform when installed), `ansible` (Lint and syntax-check Ansible when installed), `demo-preflight` (Validate repository and connected development cluster), `package` (Build a clean public source archive and checksum), `clean` (Remove generated release output).
  - **Learn from it:** Learn the repository-wide engineering convention represented by this file.

- **`README.md`**
  - **Contains:** Documentation titled **TuskerBlueprint**. TuskerBlueprint is a public reference implementation for a secure, GitOps-driven Kubernetes platform from **Stonetusker Systems**. It demonstrates how platform engineering, Argo CD, Backstage, policy enforcement, observability, and infrastructure automation can be assembled into a customer-facing portfolio and a reusable engineering baseline. Main sections include `What the reference demonstrates`, `Architecture`, `Repository map`, `Quick start`, `Security boundary`, `Backstage scope`.
  - **Learn from it:** Learn the repository-wide engineering convention represented by this file.

- **`SECURITY.md`**
  - **Contains:** Documentation titled **Security Policy**. Security fixes are applied to the latest published reference release and the `main` branch. Main sections include `Supported versions`, `Reporting a vulnerability`, `Secret handling`, `Security controls`.
  - **Learn from it:** Learn the repository-wide engineering convention represented by this file.

- **`SUPPORT.md`**
  - **Contains:** Documentation titled **Support**. Use GitHub Discussions for architecture questions and public implementation feedback. Use GitHub Issues for reproducible defects and approved enhancements. Security concerns must follow [SECURITY.md](SECURITY.md) and must not be posted publicly.
  - **Learn from it:** Learn the repository-wide engineering convention represented by this file.

- **`VERSION`**
  - **Contains:** Single source of the repository release version: `1.0.0`.
  - **Learn from it:** Learn the repository-wide engineering convention represented by this file.

- **`catalog-info.yaml`**
  - **Contains:** Backstage catalog manifest defining 6 entity/entities: `Domain/platform-engineering`, `Group/platform-engineering`, `User/subeesh`, `System/tuskerblueprint`, `Component/tuskerblueprint-platform`, `Location/tuskerblueprint-demo-service`.
  - **Learn from it:** Learn the repository-wide engineering convention represented by this file.

- **`mkdocs.yml`**
  - **Contains:** MkDocs and TechDocs site configuration: site metadata, navigation, Markdown extensions, plugins, and documentation theme settings.
  - **Learn from it:** Learn the repository-wide engineering convention represented by this file.

- **`renovate.json`**
  - **Contains:** Renovate configuration for controlled dependency, image, GitHub Action, Helm, Terraform, and Ansible update pull requests.
  - **Learn from it:** Learn the repository-wide engineering convention represented by this file.

## `.github`

GitHub governance and automated quality gates. These files define who reviews changes and what evidence every pull request must produce.

### `.github` top-level files

- **`.github/CODEOWNERS`**
  - **Contains:** GitHub ownership rules assigning mandatory review responsibility for repository areas to the platform maintainers.
  - **Learn from it:** Learn how governance, ownership, issues, reviews, and dependency automation support a maintainable public project.

### `.github/ISSUE_TEMPLATE`

- **`.github/ISSUE_TEMPLATE/bug_report.md`**
  - **Contains:** Documentation titled **Description**. It records project guidance and reference information. Main sections include `Expected Behavior`, `Actual Behavior`, `Steps to Reproduce`, `Environment`, `Additional Information`.
  - **Learn from it:** Learn how governance, ownership, issues, reviews, and dependency automation support a maintainable public project.

- **`.github/ISSUE_TEMPLATE/feature_request.md`**
  - **Contains:** Documentation titled **Problem Statement**. It records project guidance and reference information. Main sections include `Proposed Solution`, `Alternatives Considered`, `Architecture Impact`, `Acceptance Criteria`.
  - **Learn from it:** Learn how governance, ownership, issues, reviews, and dependency automation support a maintainable public project.

- **`.github/ISSUE_TEMPLATE/task.md`**
  - **Contains:** Documentation titled **Objective**. It records project guidance and reference information. Main sections include `Deliverables`, `Dependencies`, `Validation`, `Definition of Done`.
  - **Learn from it:** Learn how governance, ownership, issues, reviews, and dependency automation support a maintainable public project.

### `.github` top-level files

- **`.github/PULL_REQUEST_TEMPLATE.md`**
  - **Contains:** Documentation titled **Summary**. Describe the problem, the change, and why this implementation is appropriate. Main sections include `Specification`, `Change type`, `Validation evidence`, `Security and operations`, `Rollback`.
  - **Learn from it:** Learn how governance, ownership, issues, reviews, and dependency automation support a maintainable public project.

- **`.github/dependabot.yml`**
  - **Contains:** Dependabot update configuration defining package ecosystems, directories, schedules, limits, labels, and reviewers for automated dependency pull requests.
  - **Learn from it:** Learn how governance, ownership, issues, reviews, and dependency automation support a maintainable public project.

### `.github/workflows`

- **`.github/workflows/ansible.yml`**
  - **Contains:** GitHub Actions workflow **Ansible Validation**, triggered by pull_request, push. It defines 1 job(s): ansible (Install Ansible tooling, Install collections, Lint, Syntax check). 
  - **Learn from it:** Learn how repository promises are converted into repeatable CI evidence with least-privilege workflow permissions.

- **`.github/workflows/backstage.yml`**
  - **Contains:** GitHub Actions workflow **Backstage Configuration**, triggered by pull_request. It defines 1 job(s): configuration (Validate catalog and Backstage YAML, Confirm demo entity requirements). 
  - **Learn from it:** Learn how repository promises are converted into repeatable CI evidence with least-privilege workflow permissions.

- **`.github/workflows/ci.yml`**
  - **Contains:** GitHub Actions workflow **Repository CI**, triggered by pull_request, push. It defines 1 job(s): Repository policy and syntax (Checkout, Set up Python, Install validation dependency, Validate repository, Run ShellCheck). 
  - **Learn from it:** Learn how repository promises are converted into repeatable CI evidence with least-privilege workflow permissions.

- **`.github/workflows/gitops.yml`**
  - **Contains:** GitHub Actions workflow **GitOps Validation**, triggered by pull_request, push. It defines 1 job(s): render (Render environment, Validate rendered Kubernetes objects). 
  - **Learn from it:** Learn how repository promises are converted into repeatable CI evidence with least-privilege workflow permissions.

- **`.github/workflows/kubernetes.yml`**
  - **Contains:** GitHub Actions workflow **Kubernetes Policy Validation**, triggered by pull_request. It defines 1 job(s): policy (Render workload overlays, Repository workload policy). 
  - **Learn from it:** Learn how repository promises are converted into repeatable CI evidence with least-privilege workflow permissions.

- **`.github/workflows/observability.yml`**
  - **Contains:** GitHub Actions workflow **Observability Configuration**, triggered by pull_request. It defines 1 job(s): validate. 
  - **Learn from it:** Learn how repository promises are converted into repeatable CI evidence with least-privilege workflow permissions.

- **`.github/workflows/release.yml`**
  - **Contains:** GitHub Actions workflow **Reference Release**, triggered by workflow_dispatch, push. It defines 1 job(s): release (Validate requested version, Validate and scan repository, Package public source, Generate source SBOM, Attest source archive…). 
  - **Learn from it:** Learn how repository promises are converted into repeatable CI evidence with least-privilege workflow permissions.

- **`.github/workflows/security.yml`**
  - **Contains:** GitHub Actions workflow **Security**, triggered by pull_request, push, schedule. It defines 2 job(s): Git history secret scan, Filesystem and IaC scan (Trivy gate). 
  - **Learn from it:** Learn how repository promises are converted into repeatable CI evidence with least-privilege workflow permissions.

- **`.github/workflows/terraform.yml`**
  - **Contains:** GitHub Actions workflow **Terraform Validation**, triggered by pull_request, push. It defines 1 job(s): terraform (Format, Initialize without backend, Validate). 
  - **Learn from it:** Learn how repository promises are converted into repeatable CI evidence with least-privilege workflow permissions.

## `docs`

Human-facing architecture, standards, operations, security, migration, demo, and decision records.

### `docs` top-level files

- **`docs/ARCHITECTURE.md`**
  - **Contains:** Documentation titled **TuskerBlueprint Architecture**. TuskerBlueprint demonstrates a secure platform delivery model suitable for architecture reviews, customer demonstrations, engineering enablement, and adaptation into a production platform. Main sections include `Purpose`, `Ownership boundaries`, `GitOps hierarchy`, `Deployment environments`, `Backstage boundary`, `Security model`.
  - **Learn from it:** Use this as operational or architectural context before changing implementation files.

- **`docs/COPILOT-INSTRUCTIONS.md`**
  - **Contains:** Documentation titled **TuskerBlueprint AI Implementation Instructions**. This document provides implementation instructions for AI coding assistants, including GitHub Copilot, ChatGPT, and other Large Language Models (LLMs). Main sections include `Purpose`, `Primary Objective`, `Architecture Authority`, `Platform Ownership Model`, `Bootstrap Boundary`, `Approved Technology Stack`.
  - **Learn from it:** Use this as operational or architectural context before changing implementation files.

- **`docs/DEMO-RUNBOOK.md`**
  - **Contains:** Documentation titled **Customer Demo Runbook**. **From Git Commit to Reconciled Platform: TuskerBlueprint with Argo CD and Backstage** Main sections include `Demo title`, `Demonstration outcome`, `Supported claim`, `Preflight`, `20-minute flow`, `1. Platform story — 3 minutes`.
  - **Learn from it:** Use this as operational or architectural context before changing implementation files.

- **`docs/ENGINEERING-STANDARDS.md`**
  - **Contains:** Documentation titled **Engineering Standards**. TuskerBlueprint changes must be secure by default, deterministic, reviewable, idempotent, observable, documented, and reversible through Git. Main sections include `Principles`, `Definition of done`, `Ownership`, `Failure behavior`, `Version management`.
  - **Learn from it:** Use this as operational or architectural context before changing implementation files.

- **`docs/GITOPS-STANDARDS.md`**
  - **Contains:** Documentation titled **GitOps Standards**. Git is the authoritative desired state after Argo CD bootstrap. Argo CD uses automated sync, pruning, and self-heal. A manual cluster change is either an intentional short-lived drift demonstration or an incident action that must be recorded and reconciled back to Git. Main sections include `Source of truth`, `Hierarchy`, `Application requirements`, `AppProject requirements`, `Promotion`.
  - **Learn from it:** Use this as operational or architectural context before changing implementation files.

- **`docs/IMPLEMENTATION-GUIDE.md`**
  - **Contains:** Documentation titled **TuskerBlueprint Implementation Guide**. This document is the primary implementation guide for the TuskerBlueprint Platform. Main sections include `Purpose`, `Implementation Status`, `Platform Vision`, `Core Principles`, `Git`, `GitOps`.
  - **Learn from it:** Use this as operational or architectural context before changing implementation files.

- **`docs/IMPLEMENTATION-WORKFLOW.md`**
  - **Contains:** Documentation titled **TuskerBlueprint Implementation Workflow**. This document defines the standard workflow for implementing, reviewing, validating, releasing, and maintaining platform capabilities within the TuskerBlueprint Platform. Main sections include `Purpose`, `Platform Engineering Workflow`, `Planning Phase`, `Implementation Phase`, `Repository Changes`, `Documentation`.
  - **Learn from it:** Use this as operational or architectural context before changing implementation files.

- **`docs/MIGRATION-FROM-EXISTING-CLUSTER.md`**
  - **Contains:** Documentation titled **Migration from the Existing TuskerBlueprint Cluster**. The revised public reference changes Argo CD Application names, source URLs, projects, environment composition, and the reference workload model. Pushing the entire archive directly to the branch currently watched by `platform-root` can cause child Applications to be pruned and recreated. Migrate in reviewed stages. Main sections include `Do not replace the tracked branch directly`, `Name mapping`, `Stage 0: credential containment`, `Stage 1: prepare an isolated branch`, `Stage 2: inspect deletion behavior`, `Stage 3: migrate platform projects first`.
  - **Learn from it:** Use this as operational or architectural context before changing implementation files.

- **`docs/OPERATIONS-RUNBOOK.md`**
  - **Contains:** Documentation titled **Operations Runbook**. Review Argo CD Application conditions, non-ready pods, restarts, warning events, certificate expiry, storage capacity, and unresolved policy reports. Main sections include `Daily health`, `Safe change sequence`, `Incident response`, `Backup and restore`, `Upgrade control`.
  - **Learn from it:** Use this as operational or architectural context before changing implementation files.

- **`docs/PLATFORM-STANDARDS.md`**
  - **Contains:** Documentation titled **Platform Standards**. Each platform capability has an owner, supported consumer contract, pinned version, environment values, health verification, upgrade path, and rollback. Capabilities are independently deployable and avoid overlapping ownership. Main sections include `Platform products`, `Default posture`, `Environment posture`.
  - **Learn from it:** Use this as operational or architectural context before changing implementation files.

- **`docs/PUBLIC-RELEASE-CHECKLIST.md`**
  - **Contains:** Documentation titled **Public Release Checklist**. repository credential, and API tokens have been rotated where applicable. Main sections include `Blocking security checks`, `Quality checks`, `Archive check`.
  - **Learn from it:** Use this as operational or architectural context before changing implementation files.

- **`docs/REPOSITORY-IMPROVEMENT-REPORT.md`**
  - **Contains:** Documentation titled **Repository Improvement Report**. Transform the existing working GitOps project into a safe public portfolio and a credible reference implementation without overstating incomplete capabilities. Main sections include `Goal`, `Implemented improvements`, `Deliberately not claimed as complete`.
  - **Learn from it:** Use this as operational or architectural context before changing implementation files.

- **`docs/REPOSITORY-STANDARDS.md`**
  - **Contains:** Documentation titled **Repository Standards**. Structural changes require an ADR when they alter ownership, security boundaries, environment strategy, or the customer-facing platform model. Main sections include `Layout`, `Files`, `Public documentation`.
  - **Learn from it:** Use this as operational or architectural context before changing implementation files.

- **`docs/SECURITY-ARCHITECTURE.md`**
  - **Contains:** Documentation titled **Security Architecture**. TuskerBlueprint applies least privilege, secret externalization, immutable change control, policy enforcement, and auditable reconciliation. The public repository itself is treated as an untrusted distribution channel: it contains configuration and examples but no credential required to access a live system. Main sections include `Security objectives`, `Credential lifecycle`, `Trust boundaries`, `Repository controls`, `Kubernetes workload baseline`, `Public-release incident response`.
  - **Learn from it:** Use this as operational or architectural context before changing implementation files.

- **`docs/SECURITY-STANDARDS.md`**
  - **Contains:** Documentation titled **Security Standards**. Passwords, API tokens, private keys, credential-bearing certificates, state, kubeconfigs, runtime exports, live infrastructure addresses, and rendered secret manifests are forbidden. Public certificates and example resource names may be committed only when they grant no access and reveal no customer data. Main sections include `Repository`, `Identity and secrets`, `Kubernetes`, `Supply chain`, `Change control`.
  - **Learn from it:** Use this as operational or architectural context before changing implementation files.

- **`docs/THREAT-MODEL.md`**
  - **Contains:** Documentation titled **Threat Model**. This threat model covers the public source repository, CI workflows, Argo CD bootstrap and reconciliation, the Kubernetes platform, Backstage catalog, and the customer demo workload. Customer-specific identity providers, cloud accounts, and managed data services require separate assessments. Main sections include `Scope`, `Assets`, `Principal threats and controls`, `Residual risks`, `Review triggers`.
  - **Learn from it:** Use this as operational or architectural context before changing implementation files.

- **`docs/VALIDATION-STANDARDS.md`**
  - **Contains:** Documentation titled **Validation Standards**. This parses YAML with duplicate-key detection, validates Kustomize references and duplicate identities, checks shell syntax, validates Markdown links, enforces repository policy, and runs available secret and misconfiguration scanners. Main sections include `Required local gate`, `CI gate`, `Runtime evidence`, `Evidence quality`.
  - **Learn from it:** Use this as operational or architectural context before changing implementation files.

### `docs/architecture-decisions`

- **`docs/architecture-decisions/ADR-0001-gitops-ownership.md`**
  - **Contains:** Documentation titled **ADR-0001 – Platform Ownership Model**. Accepted Main sections include `Status`, `Context`, `Decision`, `Consequences`.
  - **Learn from it:** Learn the reason behind an architectural choice, its alternatives, and its consequences—not only the final YAML.

- **`docs/architecture-decisions/ADR-0002-bootstrap-strategy.md`**
  - **Contains:** Documentation titled **ADR-0002 – Platform Bootstrap Strategy**. Accepted Main sections include `Status`, `Context`, `Decision`, `Consequences`.
  - **Learn from it:** Learn the reason behind an architectural choice, its alternatives, and its consequences—not only the final YAML.

- **`docs/architecture-decisions/ADR-0003-platform-service-layout.md`**
  - **Contains:** Documentation titled **ADR-0003 – Platform Service Repository Layout**. Accepted Main sections include `Status`, `Context`, `Decision`, `Consequences`.
  - **Learn from it:** Learn the reason behind an architectural choice, its alternatives, and its consequences—not only the final YAML.

- **`docs/architecture-decisions/ADR-0004-argocd-native-helm.md`**
  - **Contains:** Documentation titled **ADR-0004 – Argo CD Native Helm**. Accepted Main sections include `Status`, `Context`, `Decision`, `Consequences`.
  - **Learn from it:** Learn the reason behind an architectural choice, its alternatives, and its consequences—not only the final YAML.

- **`docs/architecture-decisions/ADR-0005-environment-strategy.md`**
  - **Contains:** Documentation titled **ADR-0005 – Environment Strategy**. Accepted Main sections include `Status`, `Context`, `Decision`, `Consequences`.
  - **Learn from it:** Learn the reason behind an architectural choice, its alternatives, and its consequences—not only the final YAML.

- **`docs/architecture-decisions/README.md`**
  - **Contains:** Documentation titled **Architecture Decision Records (ADRs)**. Architecture Decision Records (ADRs) capture significant architectural decisions made during the evolution of the TuskerBlueprint Platform. Main sections include `Purpose`, `ADR Lifecycle`, `Naming Convention`.
  - **Learn from it:** Learn the reason behind an architectural choice, its alternatives, and its consequences—not only the final YAML.

### `docs` top-level files

- **`docs/platform-roadmap.md`**
  - **Contains:** Documentation titled **Platform Roadmap and Capability Maturity**. Status terms: Main sections include `Next priorities`.
  - **Learn from it:** Use this as operational or architectural context before changing implementation files.

- **`docs/platform-versions.md`**
  - **Contains:** Documentation titled **Platform Version Matrix**. This matrix records versions pinned in the repository. It does not claim that a version is the latest available; Renovate proposes upgrades and maintainers validate compatibility before merge. Main sections include `Upgrade procedure`.
  - **Learn from it:** Use this as operational or architectural context before changing implementation files.

## `specs`

Specification-driven requirements, acceptance criteria, and traceability linking intent to implementation and tests.

### `specs` top-level files

- **`specs/README.md`**
  - **Contains:** Documentation titled **Specification Index**. TuskerBlueprint uses specification-driven development. A specification defines the problem, scope, requirements, acceptance criteria, validation evidence, and rollback expectations before or alongside implementation.
  - **Learn from it:** Learn specification-driven development: requirements and acceptance criteria should trace to implementation and validation.

- **`specs/TBP-001-PLATFORM-REFERENCE.md`**
  - **Contains:** Documentation titled **TBP-001: Platform Reference**. Accepted Main sections include `Status`, `Owner`, `Problem`, `Requirements`, `Acceptance criteria`, `Rollback`.
  - **Learn from it:** Learn specification-driven development: requirements and acceptance criteria should trace to implementation and validation.

- **`specs/TBP-002-GITOPS-CONTROL-PLANE.md`**
  - **Contains:** Documentation titled **TBP-002: GitOps Control Plane**. Accepted Main sections include `Status`, `Requirements`, `Acceptance criteria`.
  - **Learn from it:** Learn specification-driven development: requirements and acceptance criteria should trace to implementation and validation.

- **`specs/TBP-003-BACKSTAGE-DEMO.md`**
  - **Contains:** Documentation titled **TBP-003: Backstage Demo Experience**. Accepted Main sections include `Status`, `User story`, `Requirements`, `Acceptance criteria`.
  - **Learn from it:** Learn specification-driven development: requirements and acceptance criteria should trace to implementation and validation.

- **`specs/TBP-004-SECURITY-CONTROLS.md`**
  - **Contains:** Documentation titled **TBP-004: Security Controls**. Accepted Main sections include `Status`, `Requirements`, `Acceptance criteria`.
  - **Learn from it:** Learn specification-driven development: requirements and acceptance criteria should trace to implementation and validation.

- **`specs/TBP-005-OBSERVABILITY.md`**
  - **Contains:** Documentation titled **TBP-005: Observability Baseline**. Accepted Main sections include `Status`, `Requirements`, `Acceptance criteria`.
  - **Learn from it:** Learn specification-driven development: requirements and acceptance criteria should trace to implementation and validation.

- **`specs/TBP-006-PUBLIC-RELEASE.md`**
  - **Contains:** Documentation titled **TBP-006: Public Release**. Accepted Main sections include `Status`, `Requirements`, `Acceptance criteria`.
  - **Learn from it:** Learn specification-driven development: requirements and acceptance criteria should trace to implementation and validation.

- **`specs/TRACEABILITY.md`**
  - **Contains:** Documentation titled **Requirements Traceability**. It records project guidance and reference information.
  - **Learn from it:** Learn specification-driven development: requirements and acceptance criteria should trace to implementation and validation.

## `gitops`

The desired-state control plane: Argo CD trust anchors, AppProjects, Applications, and environment composition.

### `gitops/applications`

- **`gitops/applications/kustomization.yaml`**
  - **Contains:** Kustomize composition listing 2 resource(s). Resources: `platform`, `workloads`. Additional behavior: plain composition only.
  - **Learn from it:** Learn how one Argo CD Application represents one deployable capability and references environment-specific configuration.

- **`gitops/applications/platform/developer-platform/backstage/application-development.yaml`**
  - **Contains:** Argo CD `Application` **backstage-development** in project `platform`. It deploys Helm chart `backstage` from `https://backstage.github.io/charts` at `1.10.0` using values `$values/platform-services/backstage/values/development.yaml`; values/reference source `values` from `https://github.com/stonetusker/tuskerblueprint.git` at `main` into namespace `backstage` with automated synchronization, pruning, self-healing.
  - **Learn from it:** Learn how one Argo CD Application represents one deployable capability and references environment-specific configuration.

- **`gitops/applications/platform/developer-platform/backstage/application-production.yaml`**
  - **Contains:** Argo CD `Application` **backstage-production** in project `platform`. It deploys Helm chart `backstage` from `https://backstage.github.io/charts` at `1.10.0` using values `$values/platform-services/backstage/values/production.yaml`; values/reference source `values` from `https://github.com/stonetusker/tuskerblueprint.git` at `main` into namespace `backstage-production` with automated synchronization, pruning, self-healing.
  - **Learn from it:** Learn how one Argo CD Application represents one deployable capability and references environment-specific configuration.

- **`gitops/applications/platform/developer-platform/backstage/application-staging.yaml`**
  - **Contains:** Argo CD `Application` **backstage-staging** in project `platform`. It deploys Helm chart `backstage` from `https://backstage.github.io/charts` at `1.10.0` using values `$values/platform-services/backstage/values/staging.yaml`; values/reference source `values` from `https://github.com/stonetusker/tuskerblueprint.git` at `main` into namespace `backstage-staging` with automated synchronization, pruning, self-healing.
  - **Learn from it:** Learn how one Argo CD Application represents one deployable capability and references environment-specific configuration.

- **`gitops/applications/platform/developer-platform/backstage/kustomization.yaml`**
  - **Contains:** Kustomize composition listing 3 resource(s). Resources: `application-development.yaml`, `application-staging.yaml`, `application-production.yaml`. Additional behavior: plain composition only.
  - **Learn from it:** Learn how one Argo CD Application represents one deployable capability and references environment-specific configuration.

- **`gitops/applications/platform/developer-platform/kustomization.yaml`**
  - **Contains:** Kustomize composition listing 1 resource(s). Resources: `backstage`. Additional behavior: plain composition only.
  - **Learn from it:** Learn how one Argo CD Application represents one deployable capability and references environment-specific configuration.

- **`gitops/applications/platform/kustomization.yaml`**
  - **Contains:** Kustomize composition listing 4 resource(s). Resources: `networking`, `security`, `observability`, `developer-platform`. Additional behavior: plain composition only.
  - **Learn from it:** Learn how one Argo CD Application represents one deployable capability and references environment-specific configuration.

- **`gitops/applications/platform/networking/kustomization.yaml`**
  - **Contains:** Kustomize composition listing 1 resource(s). Resources: `traefik`. Additional behavior: plain composition only.
  - **Learn from it:** Learn how one Argo CD Application represents one deployable capability and references environment-specific configuration.

- **`gitops/applications/platform/networking/traefik/application-development.yaml`**
  - **Contains:** Argo CD `Application` **traefik-development** in project `platform`. It deploys Helm chart `traefik` from `https://traefik.github.io/charts` at `37.1.0` using values `$values/platform-services/traefik/values/development.yaml`; values/reference source `values` from `https://github.com/stonetusker/tuskerblueprint.git` at `main` into namespace `traefik-development` with automated synchronization, pruning, self-healing.
  - **Learn from it:** Learn how one Argo CD Application represents one deployable capability and references environment-specific configuration.

- **`gitops/applications/platform/networking/traefik/application-production.yaml`**
  - **Contains:** Argo CD `Application` **traefik-production** in project `platform`. It deploys Helm chart `traefik` from `https://traefik.github.io/charts` at `37.1.0` using values `$values/platform-services/traefik/values/production.yaml`; values/reference source `values` from `https://github.com/stonetusker/tuskerblueprint.git` at `main` into namespace `traefik-production` with automated synchronization, pruning, self-healing.
  - **Learn from it:** Learn how one Argo CD Application represents one deployable capability and references environment-specific configuration.

- **`gitops/applications/platform/networking/traefik/application-staging.yaml`**
  - **Contains:** Argo CD `Application` **traefik-staging** in project `platform`. It deploys Helm chart `traefik` from `https://traefik.github.io/charts` at `37.1.0` using values `$values/platform-services/traefik/values/staging.yaml`; values/reference source `values` from `https://github.com/stonetusker/tuskerblueprint.git` at `main` into namespace `traefik-staging` with automated synchronization, pruning, self-healing.
  - **Learn from it:** Learn how one Argo CD Application represents one deployable capability and references environment-specific configuration.

- **`gitops/applications/platform/networking/traefik/kustomization.yaml`**
  - **Contains:** Kustomize composition listing 3 resource(s). Resources: `application-development.yaml`, `application-staging.yaml`, `application-production.yaml`. Additional behavior: plain composition only.
  - **Learn from it:** Learn how one Argo CD Application represents one deployable capability and references environment-specific configuration.

- **`gitops/applications/platform/observability/grafana/application-development.yaml`**
  - **Contains:** Argo CD `Application` **grafana-development** in project `platform`. It deploys Helm chart `grafana` from `https://grafana.github.io/helm-charts` at `8.10.0` using values `$values/platform-services/grafana/values/development.yaml`; values/reference source `values` from `https://github.com/stonetusker/tuskerblueprint.git` at `main` into namespace `grafana` with automated synchronization, pruning, self-healing.
  - **Learn from it:** Learn how one Argo CD Application represents one deployable capability and references environment-specific configuration.

- **`gitops/applications/platform/observability/grafana/application-production.yaml`**
  - **Contains:** Argo CD `Application` **grafana-production** in project `platform`. It deploys Helm chart `grafana` from `https://grafana.github.io/helm-charts` at `8.10.0` using values `$values/platform-services/grafana/values/production.yaml`; values/reference source `values` from `https://github.com/stonetusker/tuskerblueprint.git` at `main` into namespace `grafana-production` with automated synchronization, pruning, self-healing.
  - **Learn from it:** Learn how one Argo CD Application represents one deployable capability and references environment-specific configuration.

- **`gitops/applications/platform/observability/grafana/application-staging.yaml`**
  - **Contains:** Argo CD `Application` **grafana-staging** in project `platform`. It deploys Helm chart `grafana` from `https://grafana.github.io/helm-charts` at `8.10.0` using values `$values/platform-services/grafana/values/staging.yaml`; values/reference source `values` from `https://github.com/stonetusker/tuskerblueprint.git` at `main` into namespace `grafana-staging` with automated synchronization, pruning, self-healing.
  - **Learn from it:** Learn how one Argo CD Application represents one deployable capability and references environment-specific configuration.

- **`gitops/applications/platform/observability/grafana/kustomization.yaml`**
  - **Contains:** Kustomize composition listing 3 resource(s). Resources: `application-development.yaml`, `application-staging.yaml`, `application-production.yaml`. Additional behavior: plain composition only.
  - **Learn from it:** Learn how one Argo CD Application represents one deployable capability and references environment-specific configuration.

- **`gitops/applications/platform/observability/kustomization.yaml`**
  - **Contains:** Kustomize composition listing 3 resource(s). Resources: `prometheus`, `loki`, `grafana`. Additional behavior: plain composition only.
  - **Learn from it:** Learn how one Argo CD Application represents one deployable capability and references environment-specific configuration.

- **`gitops/applications/platform/observability/loki/application-development.yaml`**
  - **Contains:** Argo CD `Application` **loki-development** in project `platform`. It deploys Helm chart `loki` from `https://grafana.github.io/helm-charts` at `6.29.0` using values `$values/platform-services/loki/values/development.yaml`; values/reference source `values` from `https://github.com/stonetusker/tuskerblueprint.git` at `main` into namespace `monitoring` with automated synchronization, pruning, self-healing.
  - **Learn from it:** Learn how one Argo CD Application represents one deployable capability and references environment-specific configuration.

- **`gitops/applications/platform/observability/loki/application-production.yaml`**
  - **Contains:** Argo CD `Application` **loki-production** in project `platform`. It deploys Helm chart `loki` from `https://grafana.github.io/helm-charts` at `6.29.0` using values `$values/platform-services/loki/values/production.yaml`; values/reference source `values` from `https://github.com/stonetusker/tuskerblueprint.git` at `main` into namespace `monitoring` with automated synchronization, pruning, self-healing.
  - **Learn from it:** Learn how one Argo CD Application represents one deployable capability and references environment-specific configuration.

- **`gitops/applications/platform/observability/loki/application-staging.yaml`**
  - **Contains:** Argo CD `Application` **loki-staging** in project `platform`. It deploys Helm chart `loki` from `https://grafana.github.io/helm-charts` at `6.29.0` using values `$values/platform-services/loki/values/staging.yaml`; values/reference source `values` from `https://github.com/stonetusker/tuskerblueprint.git` at `main` into namespace `monitoring` with automated synchronization, pruning, self-healing.
  - **Learn from it:** Learn how one Argo CD Application represents one deployable capability and references environment-specific configuration.

- **`gitops/applications/platform/observability/loki/kustomization.yaml`**
  - **Contains:** Kustomize composition listing 3 resource(s). Resources: `application-development.yaml`, `application-staging.yaml`, `application-production.yaml`. Additional behavior: plain composition only.
  - **Learn from it:** Learn how one Argo CD Application represents one deployable capability and references environment-specific configuration.

- **`gitops/applications/platform/observability/prometheus/application-development.yaml`**
  - **Contains:** Argo CD `Application` **prometheus-development** in project `platform`. It deploys Helm chart `prometheus` from `https://prometheus-community.github.io/helm-charts` at `27.3.0` using values `$values/platform-services/prometheus/values/development.yaml`; values/reference source `values` from `https://github.com/stonetusker/tuskerblueprint.git` at `main` into namespace `monitoring` with automated synchronization, pruning, self-healing.
  - **Learn from it:** Learn how one Argo CD Application represents one deployable capability and references environment-specific configuration.

- **`gitops/applications/platform/observability/prometheus/application-production.yaml`**
  - **Contains:** Argo CD `Application` **prometheus-production** in project `platform`. It deploys Helm chart `prometheus` from `https://prometheus-community.github.io/helm-charts` at `27.3.0` using values `$values/platform-services/prometheus/values/production.yaml`; values/reference source `values` from `https://github.com/stonetusker/tuskerblueprint.git` at `main` into namespace `monitoring` with automated synchronization, pruning, self-healing.
  - **Learn from it:** Learn how one Argo CD Application represents one deployable capability and references environment-specific configuration.

- **`gitops/applications/platform/observability/prometheus/application-staging.yaml`**
  - **Contains:** Argo CD `Application` **prometheus-staging** in project `platform`. It deploys Helm chart `prometheus` from `https://prometheus-community.github.io/helm-charts` at `27.3.0` using values `$values/platform-services/prometheus/values/staging.yaml`; values/reference source `values` from `https://github.com/stonetusker/tuskerblueprint.git` at `main` into namespace `monitoring` with automated synchronization, pruning, self-healing.
  - **Learn from it:** Learn how one Argo CD Application represents one deployable capability and references environment-specific configuration.

- **`gitops/applications/platform/observability/prometheus/kustomization.yaml`**
  - **Contains:** Kustomize composition listing 3 resource(s). Resources: `application-development.yaml`, `application-staging.yaml`, `application-production.yaml`. Additional behavior: plain composition only.
  - **Learn from it:** Learn how one Argo CD Application represents one deployable capability and references environment-specific configuration.

- **`gitops/applications/platform/security/cert-manager/application-development.yaml`**
  - **Contains:** Argo CD `Application` **cert-manager-development** in project `platform`. It deploys Helm chart `cert-manager` from `https://charts.jetstack.io` at `v1.21.0` using values `$values/platform-services/cert-manager/values/development.yaml`; values/reference source `values` from `https://github.com/stonetusker/tuskerblueprint.git` at `main` into namespace `cert-manager` with automated synchronization, pruning, self-healing.
  - **Learn from it:** Learn how one Argo CD Application represents one deployable capability and references environment-specific configuration.

- **`gitops/applications/platform/security/cert-manager/application-production.yaml`**
  - **Contains:** Argo CD `Application` **cert-manager-production** in project `platform`. It deploys Helm chart `cert-manager` from `https://charts.jetstack.io` at `v1.21.0` using values `$values/platform-services/cert-manager/values/production.yaml`; values/reference source `values` from `https://github.com/stonetusker/tuskerblueprint.git` at `main` into namespace `cert-manager-production` with automated synchronization, pruning, self-healing.
  - **Learn from it:** Learn how one Argo CD Application represents one deployable capability and references environment-specific configuration.

- **`gitops/applications/platform/security/cert-manager/application-staging.yaml`**
  - **Contains:** Argo CD `Application` **cert-manager-staging** in project `platform`. It deploys Helm chart `cert-manager` from `https://charts.jetstack.io` at `v1.21.0` using values `$values/platform-services/cert-manager/values/staging.yaml`; values/reference source `values` from `https://github.com/stonetusker/tuskerblueprint.git` at `main` into namespace `cert-manager-staging` with automated synchronization, pruning, self-healing.
  - **Learn from it:** Learn how one Argo CD Application represents one deployable capability and references environment-specific configuration.

- **`gitops/applications/platform/security/cert-manager/kustomization.yaml`**
  - **Contains:** Kustomize composition listing 3 resource(s). Resources: `application-development.yaml`, `application-staging.yaml`, `application-production.yaml`. Additional behavior: plain composition only.
  - **Learn from it:** Learn how one Argo CD Application represents one deployable capability and references environment-specific configuration.

- **`gitops/applications/platform/security/doppler/application-development.yaml`**
  - **Contains:** Argo CD `Application` **doppler-development** in project `platform`. It deploys Helm chart `doppler-operator` from `https://helm.doppler.com` at `1.5.0` using values `$values/platform-services/doppler/values/development.yaml`; values/reference source `values` from `https://github.com/stonetusker/tuskerblueprint.git` at `main` into namespace `doppler` with automated synchronization, pruning, self-healing.
  - **Learn from it:** Learn how one Argo CD Application represents one deployable capability and references environment-specific configuration.

- **`gitops/applications/platform/security/doppler/application-production.yaml`**
  - **Contains:** Argo CD `Application` **doppler-production** in project `platform`. It deploys Helm chart `doppler-operator` from `https://helm.doppler.com` at `1.5.0` using values `$values/platform-services/doppler/values/production.yaml`; values/reference source `values` from `https://github.com/stonetusker/tuskerblueprint.git` at `main` into namespace `doppler-production` with automated synchronization, pruning, self-healing.
  - **Learn from it:** Learn how one Argo CD Application represents one deployable capability and references environment-specific configuration.

- **`gitops/applications/platform/security/doppler/application-staging.yaml`**
  - **Contains:** Argo CD `Application` **doppler-staging** in project `platform`. It deploys Helm chart `doppler-operator` from `https://helm.doppler.com` at `1.5.0` using values `$values/platform-services/doppler/values/staging.yaml`; values/reference source `values` from `https://github.com/stonetusker/tuskerblueprint.git` at `main` into namespace `doppler-staging` with automated synchronization, pruning, self-healing.
  - **Learn from it:** Learn how one Argo CD Application represents one deployable capability and references environment-specific configuration.

- **`gitops/applications/platform/security/doppler/kustomization.yaml`**
  - **Contains:** Kustomize composition listing 3 resource(s). Resources: `application-development.yaml`, `application-staging.yaml`, `application-production.yaml`. Additional behavior: plain composition only.
  - **Learn from it:** Learn how one Argo CD Application represents one deployable capability and references environment-specific configuration.

- **`gitops/applications/platform/security/external-secrets/application-development.yaml`**
  - **Contains:** Argo CD `Application` **external-secrets-development** in project `platform`. It deploys Helm chart `external-secrets` from `https://charts.external-secrets.io` at `0.14.2` using values `$values/platform-services/external-secrets/values/development.yaml`; values/reference source `values` from `https://github.com/stonetusker/tuskerblueprint.git` at `main` into namespace `external-secrets` with automated synchronization, pruning, self-healing.
  - **Learn from it:** Learn how one Argo CD Application represents one deployable capability and references environment-specific configuration.

- **`gitops/applications/platform/security/external-secrets/application-production.yaml`**
  - **Contains:** Argo CD `Application` **external-secrets-production** in project `platform`. It deploys Helm chart `external-secrets` from `https://charts.external-secrets.io` at `0.14.2` using values `$values/platform-services/external-secrets/values/production.yaml`; values/reference source `values` from `https://github.com/stonetusker/tuskerblueprint.git` at `main` into namespace `external-secrets-production` with automated synchronization, pruning, self-healing.
  - **Learn from it:** Learn how one Argo CD Application represents one deployable capability and references environment-specific configuration.

- **`gitops/applications/platform/security/external-secrets/application-staging.yaml`**
  - **Contains:** Argo CD `Application` **external-secrets-staging** in project `platform`. It deploys Helm chart `external-secrets` from `https://charts.external-secrets.io` at `0.14.2` using values `$values/platform-services/external-secrets/values/staging.yaml`; values/reference source `values` from `https://github.com/stonetusker/tuskerblueprint.git` at `main` into namespace `external-secrets-staging` with automated synchronization, pruning, self-healing.
  - **Learn from it:** Learn how one Argo CD Application represents one deployable capability and references environment-specific configuration.

- **`gitops/applications/platform/security/external-secrets/kustomization.yaml`**
  - **Contains:** Kustomize composition listing 3 resource(s). Resources: `application-development.yaml`, `application-staging.yaml`, `application-production.yaml`. Additional behavior: plain composition only.
  - **Learn from it:** Learn how one Argo CD Application represents one deployable capability and references environment-specific configuration.

- **`gitops/applications/platform/security/kustomization.yaml`**
  - **Contains:** Kustomize composition listing 5 resource(s). Resources: `cert-manager`, `external-secrets`, `kyverno`, `kyverno-policies`, `doppler`. Additional behavior: plain composition only.
  - **Learn from it:** Learn how one Argo CD Application represents one deployable capability and references environment-specific configuration.

- **`gitops/applications/platform/security/kyverno-policies/application-development.yaml`**
  - **Contains:** Argo CD `Application` **kyverno-policies-development** in project `platform`. It deploys Git path `platform-services/kyverno/policies/overlays/development` from `https://github.com/stonetusker/tuskerblueprint.git` at `main` into namespace `kyverno` with automated synchronization, pruning, self-healing.
  - **Learn from it:** Learn how one Argo CD Application represents one deployable capability and references environment-specific configuration.

- **`gitops/applications/platform/security/kyverno-policies/application-production.yaml`**
  - **Contains:** Argo CD `Application` **kyverno-policies-production** in project `platform`. It deploys Git path `platform-services/kyverno/policies/overlays/production` from `https://github.com/stonetusker/tuskerblueprint.git` at `main` into namespace `kyverno-production` with automated synchronization, pruning, self-healing.
  - **Learn from it:** Learn how one Argo CD Application represents one deployable capability and references environment-specific configuration.

- **`gitops/applications/platform/security/kyverno-policies/application-staging.yaml`**
  - **Contains:** Argo CD `Application` **kyverno-policies-staging** in project `platform`. It deploys Git path `platform-services/kyverno/policies/overlays/staging` from `https://github.com/stonetusker/tuskerblueprint.git` at `main` into namespace `kyverno-staging` with automated synchronization, pruning, self-healing.
  - **Learn from it:** Learn how one Argo CD Application represents one deployable capability and references environment-specific configuration.

- **`gitops/applications/platform/security/kyverno-policies/kustomization.yaml`**
  - **Contains:** Kustomize composition listing 3 resource(s). Resources: `application-development.yaml`, `application-staging.yaml`, `application-production.yaml`. Additional behavior: plain composition only.
  - **Learn from it:** Learn how one Argo CD Application represents one deployable capability and references environment-specific configuration.

- **`gitops/applications/platform/security/kyverno/application-development.yaml`**
  - **Contains:** Argo CD `Application` **kyverno-development** in project `platform`. It deploys Helm chart `kyverno` from `https://kyverno.github.io/kyverno/` at `3.3.7` using values `$values/platform-services/kyverno/values/development.yaml`; values/reference source `values` from `https://github.com/stonetusker/tuskerblueprint.git` at `main` into namespace `kyverno` with automated synchronization, pruning, self-healing.
  - **Learn from it:** Learn how one Argo CD Application represents one deployable capability and references environment-specific configuration.

- **`gitops/applications/platform/security/kyverno/application-production.yaml`**
  - **Contains:** Argo CD `Application` **kyverno-production** in project `platform`. It deploys Helm chart `kyverno` from `https://kyverno.github.io/kyverno/` at `3.3.7` using values `$values/platform-services/kyverno/values/production.yaml`; values/reference source `values` from `https://github.com/stonetusker/tuskerblueprint.git` at `main` into namespace `kyverno-production` with automated synchronization, pruning, self-healing.
  - **Learn from it:** Learn how one Argo CD Application represents one deployable capability and references environment-specific configuration.

- **`gitops/applications/platform/security/kyverno/application-staging.yaml`**
  - **Contains:** Argo CD `Application` **kyverno-staging** in project `platform`. It deploys Helm chart `kyverno` from `https://kyverno.github.io/kyverno/` at `3.3.7` using values `$values/platform-services/kyverno/values/staging.yaml`; values/reference source `values` from `https://github.com/stonetusker/tuskerblueprint.git` at `main` into namespace `kyverno-staging` with automated synchronization, pruning, self-healing.
  - **Learn from it:** Learn how one Argo CD Application represents one deployable capability and references environment-specific configuration.

- **`gitops/applications/platform/security/kyverno/kustomization.yaml`**
  - **Contains:** Kustomize composition listing 3 resource(s). Resources: `application-development.yaml`, `application-staging.yaml`, `application-production.yaml`. Additional behavior: plain composition only.
  - **Learn from it:** Learn how one Argo CD Application represents one deployable capability and references environment-specific configuration.

- **`gitops/applications/root/application.yaml`**
  - **Contains:** Argo CD `Application` **platform-root-development** in project `bootstrap`. It deploys Git path `gitops/environments/development` from `https://github.com/stonetusker/tuskerblueprint.git` at `main` into namespace `argocd` with automated synchronization, pruning, self-healing.
  - **Learn from it:** Learn the app-of-apps control-plane entry point and why root ownership must be migrated carefully.

- **`gitops/applications/root/kustomization.yaml`**
  - **Contains:** Kustomize composition listing 2 resource(s). Resources: `../../bootstrap/root-application/project.yaml`, `application.yaml`. Additional behavior: plain composition only.
  - **Learn from it:** Learn the app-of-apps control-plane entry point and why root ownership must be migrated carefully.

- **`gitops/applications/workloads/demo-service/application-development.yaml`**
  - **Contains:** Argo CD `Application` **demo-service-development** in project `workloads`. It deploys Git path `workloads/demo-service/overlays/development` from `https://github.com/stonetusker/tuskerblueprint.git` at `main` into namespace `demo-development` with automated synchronization, pruning, self-healing.
  - **Learn from it:** Learn how one Argo CD Application represents one deployable capability and references environment-specific configuration.

- **`gitops/applications/workloads/demo-service/application-production.yaml`**
  - **Contains:** Argo CD `Application` **demo-service-production** in project `workloads`. It deploys Git path `workloads/demo-service/overlays/production` from `https://github.com/stonetusker/tuskerblueprint.git` at `main` into namespace `demo-production` with automated synchronization, pruning, self-healing.
  - **Learn from it:** Learn how one Argo CD Application represents one deployable capability and references environment-specific configuration.

- **`gitops/applications/workloads/demo-service/application-staging.yaml`**
  - **Contains:** Argo CD `Application` **demo-service-staging** in project `workloads`. It deploys Git path `workloads/demo-service/overlays/staging` from `https://github.com/stonetusker/tuskerblueprint.git` at `main` into namespace `demo-staging` with automated synchronization, pruning, self-healing.
  - **Learn from it:** Learn how one Argo CD Application represents one deployable capability and references environment-specific configuration.

- **`gitops/applications/workloads/demo-service/kustomization.yaml`**
  - **Contains:** Kustomize composition listing 3 resource(s). Resources: `application-development.yaml`, `application-staging.yaml`, `application-production.yaml`. Additional behavior: plain composition only.
  - **Learn from it:** Learn how one Argo CD Application represents one deployable capability and references environment-specific configuration.

- **`gitops/applications/workloads/kustomization.yaml`**
  - **Contains:** Kustomize composition listing 1 resource(s). Resources: `demo-service`. Additional behavior: plain composition only.
  - **Learn from it:** Learn how one Argo CD Application represents one deployable capability and references environment-specific configuration.

### `gitops/bootstrap`

- **`gitops/bootstrap/README.md`**
  - **Contains:** Documentation titled **GitOps Bootstrap Boundary**. Ansible installs Argo CD, then applies the bootstrap AppProject and exactly one environment root Application from `root-application/`. All platform and workload resources after that point are owned by the selected root Application.
  - **Learn from it:** Learn the trust-anchor boundary: only the minimum root objects are applied imperatively; Argo CD owns everything afterward.

- **`gitops/bootstrap/kustomization.yaml`**
  - **Contains:** Kustomize composition listing 1 resource(s). Resources: `root-application`. Additional behavior: plain composition only.
  - **Learn from it:** Learn the trust-anchor boundary: only the minimum root objects are applied imperatively; Argo CD owns everything afterward.

- **`gitops/bootstrap/root-application/application-development.yaml`**
  - **Contains:** Argo CD `Application` **platform-root-development** in project `bootstrap`. It deploys Git path `gitops/environments/development` from `https://github.com/stonetusker/tuskerblueprint.git` at `main` into namespace `argocd` with automated synchronization, pruning, self-healing.
  - **Learn from it:** Learn the trust-anchor boundary: only the minimum root objects are applied imperatively; Argo CD owns everything afterward.

- **`gitops/bootstrap/root-application/application-production.yaml`**
  - **Contains:** Argo CD `Application` **platform-root-production** in project `bootstrap`. It deploys Git path `gitops/environments/production` from `https://github.com/stonetusker/tuskerblueprint.git` at `main` into namespace `argocd` with automated synchronization, pruning, self-healing.
  - **Learn from it:** Learn the trust-anchor boundary: only the minimum root objects are applied imperatively; Argo CD owns everything afterward.

- **`gitops/bootstrap/root-application/application-staging.yaml`**
  - **Contains:** Argo CD `Application` **platform-root-staging** in project `bootstrap`. It deploys Git path `gitops/environments/staging` from `https://github.com/stonetusker/tuskerblueprint.git` at `main` into namespace `argocd` with automated synchronization, pruning, self-healing.
  - **Learn from it:** Learn the trust-anchor boundary: only the minimum root objects are applied imperatively; Argo CD owns everything afterward.

- **`gitops/bootstrap/root-application/kustomization.yaml`**
  - **Contains:** Kustomize composition listing 2 resource(s). Resources: `project.yaml`, `application-development.yaml`. Additional behavior: plain composition only.
  - **Learn from it:** Learn the trust-anchor boundary: only the minimum root objects are applied imperatively; Argo CD owns everything afterward.

- **`gitops/bootstrap/root-application/project.yaml`**
  - **Contains:** Argo CD `AppProject` **bootstrap**. It limits allowed source repositories (1 entries), destinations (argocd@https://kubernetes.default.svc), and resource scopes (cluster whitelist 0, namespaced whitelist 3).
  - **Learn from it:** Learn the trust-anchor boundary: only the minimum root objects are applied imperatively; Argo CD owns everything afterward.

### `gitops/environments`

- **`gitops/environments/development/kustomization.yaml`**
  - **Contains:** Kustomize composition listing 12 resource(s). Resources: `../../projects/platform`, `../../projects/workloads`, `../../applications/platform/networking/traefik/application-development.yaml`, `../../applications/platform/security/cert-manager/application-development.yaml`, `../../applications/platform/security/external-secrets/application-development.yaml`, `../../applications/platform/security/kyverno/application-development.yaml`, `../../applications/platform/security/kyverno-policies/application-development.yaml`, `../../applications/platform/observability/prometheus/application-development.yaml`, `../../applications/platform/observability/loki/application-development.yaml`, `../../applications/platform/observability/grafana/application-development.yaml`…. Additional behavior: plain composition only.
  - **Learn from it:** Learn how Kustomize selects the exact applications and policies belonging to one environment without duplicating identities.

- **`gitops/environments/production/kustomization.yaml`**
  - **Contains:** Kustomize composition listing 12 resource(s). Resources: `../../projects/platform`, `../../projects/workloads`, `../../applications/platform/networking/traefik/application-production.yaml`, `../../applications/platform/security/cert-manager/application-production.yaml`, `../../applications/platform/security/external-secrets/application-production.yaml`, `../../applications/platform/security/kyverno/application-production.yaml`, `../../applications/platform/security/kyverno-policies/application-production.yaml`, `../../applications/platform/observability/prometheus/application-production.yaml`, `../../applications/platform/observability/loki/application-production.yaml`, `../../applications/platform/observability/grafana/application-production.yaml`…. Additional behavior: plain composition only.
  - **Learn from it:** Learn how Kustomize selects the exact applications and policies belonging to one environment without duplicating identities.

- **`gitops/environments/staging/kustomization.yaml`**
  - **Contains:** Kustomize composition listing 12 resource(s). Resources: `../../projects/platform`, `../../projects/workloads`, `../../applications/platform/networking/traefik/application-staging.yaml`, `../../applications/platform/security/cert-manager/application-staging.yaml`, `../../applications/platform/security/external-secrets/application-staging.yaml`, `../../applications/platform/security/kyverno/application-staging.yaml`, `../../applications/platform/security/kyverno-policies/application-staging.yaml`, `../../applications/platform/observability/prometheus/application-staging.yaml`, `../../applications/platform/observability/loki/application-staging.yaml`, `../../applications/platform/observability/grafana/application-staging.yaml`…. Additional behavior: plain composition only.
  - **Learn from it:** Learn how Kustomize selects the exact applications and policies belonging to one environment without duplicating identities.

### `gitops/projects`

- **`gitops/projects/kustomization.yaml`**
  - **Contains:** Kustomize composition listing 2 resource(s). Resources: `platform`, `workloads`. Additional behavior: plain composition only.
  - **Learn from it:** Learn how AppProjects provide multi-tenant and least-privilege boundaries around repositories, destinations, and Kubernetes resources.

- **`gitops/projects/platform/kustomization.yaml`**
  - **Contains:** Kustomize composition listing 1 resource(s). Resources: `project.yaml`. Additional behavior: plain composition only.
  - **Learn from it:** Learn how AppProjects provide multi-tenant and least-privilege boundaries around repositories, destinations, and Kubernetes resources.

- **`gitops/projects/platform/project.yaml`**
  - **Contains:** Argo CD `AppProject` **platform**. It limits allowed source repositories (9 entries), destinations (traefik-development@https://kubernetes.default.svc, traefik-staging@https://kubernetes.default.svc, traefik-production@https://kubernetes.default.svc, cert-manager@https://kubernetes.default.svc, external-secrets@https://kubernetes.default.svc, doppler@https://kubernetes.default.svc, kyverno@https://kubernetes.default.svc, monitoring@https://kubernetes.default.svc, grafana@https://kubernetes.default.svc, backstage@https://kubernetes.default.svc, backstage-staging@https://kubernetes.default.svc, backstage-production@https://kubernetes.default.svc, cert-manager-staging@https://kubernetes.default.svc, cert-manager-production@https://kubernetes.default.svc, external-secrets-staging@https://kubernetes.default.svc, external-secrets-production@https://kubernetes.default.svc, doppler-staging@https://kubernetes.default.svc, doppler-production@https://kubernetes.default.svc, kyverno-staging@https://kubernetes.default.svc, kyverno-production@https://kubernetes.default.svc, grafana-staging@https://kubernetes.default.svc, grafana-production@https://kubernetes.default.svc), and resource scopes (cluster whitelist 10, namespaced whitelist 1).
  - **Learn from it:** Learn how AppProjects provide multi-tenant and least-privilege boundaries around repositories, destinations, and Kubernetes resources.

- **`gitops/projects/workloads/kustomization.yaml`**
  - **Contains:** Kustomize composition listing 1 resource(s). Resources: `project.yaml`. Additional behavior: plain composition only.
  - **Learn from it:** Learn how AppProjects provide multi-tenant and least-privilege boundaries around repositories, destinations, and Kubernetes resources.

- **`gitops/projects/workloads/project.yaml`**
  - **Contains:** Argo CD `AppProject` **workloads**. It limits allowed source repositories (1 entries), destinations (demo-development@https://kubernetes.default.svc, demo-staging@https://kubernetes.default.svc, demo-production@https://kubernetes.default.svc), and resource scopes (cluster whitelist 0, namespaced whitelist 7).
  - **Learn from it:** Learn how AppProjects provide multi-tenant and least-privilege boundaries around repositories, destinations, and Kubernetes resources.

## `infrastructure`

Imperative bootstrap and declarative infrastructure foundations used before Argo CD assumes ownership.

### `infrastructure/ansible`

- **`infrastructure/ansible/ansible.cfg`**
  - **Contains:** Ansible runtime configuration for inventory behavior, roles path, output, host-key checking, retries, and execution defaults.
  - **Learn from it:** Learn how inventories and variables separate environment data from reusable automation.

- **`infrastructure/ansible/collections/requirements.yml`**
  - **Contains:** Pinned Ansible collection dependencies: `ansible.posix`, `community.general`, `kubernetes.core`.
  - **Learn from it:** Learn how inventories and variables separate environment data from reusable automation.

- **`infrastructure/ansible/docs/deployment-topology.md`**
  - **Contains:** Documentation titled **Deployment Topology**. All platform services are currently deployed to the single control-plane node. Main sections include `Current Environment`, `Node`, `Future Evolution`.
  - **Learn from it:** Learn how inventories and variables separate environment data from reusable automation.

- **`infrastructure/ansible/inventories/dev/group_vars/all.yml`**
  - **Contains:** Ansible variable file. It defines 10 configurable key(s): `ansible_user`, `ansible_python_interpreter`, `ansible_ssh_private_key_file`, `platform_admin_user`, `platform_environment`, `platform_timezone`, `platform_locale`, `k3s_cluster_name`, `k3s_api_endpoint`, `kubeconfig`.
  - **Learn from it:** Learn how inventories and variables separate environment data from reusable automation.

- **`infrastructure/ansible/inventories/dev/host_vars/vps8.yml`**
  - **Contains:** Ansible variable file. It defines 3 configurable key(s): `node_role`, `k3s_cluster_init`, `k3s_server`.
  - **Learn from it:** Learn how inventories and variables separate environment data from reusable automation.

- **`infrastructure/ansible/inventories/dev/hosts.yml`**
  - **Contains:** Ansible YAML inventory describing the development host groups, target hosts, and connection variables used by the playbooks.
  - **Learn from it:** Learn how inventories and variables separate environment data from reusable automation.

- **`infrastructure/ansible/playbooks/argocd.yml`**
  - **Contains:** Ansible playbook with 1 play(s): Bootstrap Argo CD on `k3s_servers` using roles argocd_bootstrap.
  - **Learn from it:** Learn how small roles are orchestrated into host bootstrap and platform installation flows.

- **`infrastructure/ansible/playbooks/bootstrap.yml`**
  - **Contains:** Ansible playbook with 1 play(s): Bootstrap Platform Hosts on `all` using roles common, users.
  - **Learn from it:** Learn how small roles are orchestrated into host bootstrap and platform installation flows.

- **`infrastructure/ansible/playbooks/common.yml`**
  - **Contains:** Ansible playbook with 1 play(s): Configure Common Operating System on `all` using roles common.
  - **Learn from it:** Learn how small roles are orchestrated into host bootstrap and platform installation flows.

- **`infrastructure/ansible/playbooks/k3s.yml`**
  - **Contains:** Ansible playbook with 1 play(s): Install k3s on `k3s_servers` using roles k3s.
  - **Learn from it:** Learn how small roles are orchestrated into host bootstrap and platform installation flows.

- **`infrastructure/ansible/playbooks/kernel.yml`**
  - **Contains:** Ansible playbook with 1 play(s): Configure Kubernetes kernel prerequisites on `k3s_servers` using roles kernel.
  - **Learn from it:** Learn how small roles are orchestrated into host bootstrap and platform installation flows.

- **`infrastructure/ansible/playbooks/kubectl.yml`**
  - **Contains:** Ansible playbook with 1 play(s): Configure kubectl on `k3s_servers` using roles kubectl.
  - **Learn from it:** Learn how small roles are orchestrated into host bootstrap and platform installation flows.

- **`infrastructure/ansible/playbooks/site.yml`**
  - **Contains:** Ansible playbook with 7 play(s): unnamed play on `?` using roles inline tasks; unnamed play on `?` using roles inline tasks; unnamed play on `?` using roles inline tasks; unnamed play on `?` using roles inline tasks; unnamed play on `?` using roles inline tasks; unnamed play on `?` using roles inline tasks; unnamed play on `?` using roles inline tasks.
  - **Learn from it:** Learn how small roles are orchestrated into host bootstrap and platform installation flows.

- **`infrastructure/ansible/playbooks/timesync.yml`**
  - **Contains:** Ansible playbook with 1 play(s): Configure time synchronization on `platform` using roles timesync.
  - **Learn from it:** Learn how small roles are orchestrated into host bootstrap and platform installation flows.

- **`infrastructure/ansible/playbooks/validate.yml`**
  - **Contains:** Ansible playbook with 1 play(s): Validate Platform Hosts on `all` using roles inline tasks.
  - **Learn from it:** Learn how small roles are orchestrated into host bootstrap and platform installation flows.

- **`infrastructure/ansible/roles/argocd_bootstrap/defaults/main.yml`**
  - **Contains:** Ansible variable file. It defines 20 configurable key(s): `argocd_namespace`, `argocd_release_name`, `argocd_chart_repo_name`, `argocd_chart_repo`, `argocd_chart_name`, `argocd_chart_version`, `argocd_wait_timeout`, `kubeconfig`, `argocd_repo_name`, `argocd_repo_url`, `argocd_repo_branch`, `argocd_repo_auth_type`, `argocd_repo_secret_name`, `argocd_repo_key_path`, `argocd_repo_username`, `argocd_repo_password`, `argocd_environment`, `argocd_root_app_name`, `argocd_bootstrap_project_manifest`, `argocd_root_app_manifest`.
  - **Learn from it:** Learn role decomposition, idempotency, variables, handlers, and secret-safe bootstrap automation.

- **`infrastructure/ansible/roles/argocd_bootstrap/files/values.yaml`**
  - **Contains:** Baseline Argo CD Helm values used by the Ansible bootstrap role. Top-level settings: `global`, `configs`, `controller`, `server`, `repoServer`, `applicationSet`, `notifications`, `dex`.
  - **Learn from it:** Learn role decomposition, idempotency, variables, handlers, and secret-safe bootstrap automation.

- **`infrastructure/ansible/roles/argocd_bootstrap/handlers/main.yml`**
  - **Contains:** YAML document containing 0 parsed document(s).
  - **Learn from it:** Learn role decomposition, idempotency, variables, handlers, and secret-safe bootstrap automation.

- **`infrastructure/ansible/roles/argocd_bootstrap/meta/main.yml`**
  - **Contains:** Ansible role metadata declaring role information, platform compatibility, tags, and/or role dependencies.
  - **Learn from it:** Learn role decomposition, idempotency, variables, handlers, and secret-safe bootstrap automation.

- **`infrastructure/ansible/roles/argocd_bootstrap/tasks/download.yml`**
  - **Contains:** Ansible role task file containing 1 named task(s): `Download pinned Argo CD manifest`.
  - **Learn from it:** Learn role decomposition, idempotency, variables, handlers, and secret-safe bootstrap automation.

- **`infrastructure/ansible/roles/argocd_bootstrap/tasks/install.yml`**
  - **Contains:** Ansible role task file containing 2 named task(s): `Configure Argo Helm repository`, `Install or upgrade Argo CD`.
  - **Learn from it:** Learn role decomposition, idempotency, variables, handlers, and secret-safe bootstrap automation.

- **`infrastructure/ansible/roles/argocd_bootstrap/tasks/main.yml`**
  - **Contains:** Ansible role task file containing 8 named task(s): `Verify bootstrap prerequisites`, `Ensure Argo CD namespace exists`, `Install or upgrade Argo CD`, `Wait for Argo CD`, `Verify Argo CD installation`, `Register authenticated Git repository`, `Bootstrap selected environment root Application`, `Validate bootstrap`.
  - **Learn from it:** Learn role decomposition, idempotency, variables, handlers, and secret-safe bootstrap automation.

- **`infrastructure/ansible/roles/argocd_bootstrap/tasks/namespace.yml`**
  - **Contains:** Ansible role task file containing 1 named task(s): `Ensure Argo CD namespace exists`.
  - **Learn from it:** Learn role decomposition, idempotency, variables, handlers, and secret-safe bootstrap automation.

- **`infrastructure/ansible/roles/argocd_bootstrap/tasks/prerequisites.yml`**
  - **Contains:** Ansible role task file containing 4 named task(s): `Verify kubectl is installed on the control node`, `Verify Helm is installed on the control node`, `Verify kubeconfig exists`, `Require a readable kubeconfig`.
  - **Learn from it:** Learn role decomposition, idempotency, variables, handlers, and secret-safe bootstrap automation.

- **`infrastructure/ansible/roles/argocd_bootstrap/tasks/repository.yml`**
  - **Contains:** Ansible role task file containing 5 named task(s): `Validate private repository authentication type`, `Validate SSH repository credential input`, `Register SSH repository without writing a rendered Secret to disk`, `Validate HTTPS repository credential input`, `Register HTTPS repository without writing a rendered Secret to disk`.
  - **Learn from it:** Learn role decomposition, idempotency, variables, handlers, and secret-safe bootstrap automation.

- **`infrastructure/ansible/roles/argocd_bootstrap/tasks/root_application.yml`**
  - **Contains:** Ansible role task file containing 2 named task(s): `Apply bootstrap AppProject`, `Apply selected environment root Application`.
  - **Learn from it:** Learn role decomposition, idempotency, variables, handlers, and secret-safe bootstrap automation.

- **`infrastructure/ansible/roles/argocd_bootstrap/tasks/validation.yml`**
  - **Contains:** Ansible role task file containing 3 named task(s): `Verify authenticated repository Secret when configured`, `Verify root Application`, `Require the root Application to exist`.
  - **Learn from it:** Learn role decomposition, idempotency, variables, handlers, and secret-safe bootstrap automation.

- **`infrastructure/ansible/roles/argocd_bootstrap/tasks/verify.yml`**
  - **Contains:** Ansible role task file containing 2 named task(s): `Read Argo CD deployments`, `Assert Argo CD has available deployments`.
  - **Learn from it:** Learn role decomposition, idempotency, variables, handlers, and secret-safe bootstrap automation.

- **`infrastructure/ansible/roles/argocd_bootstrap/tasks/wait.yml`**
  - **Contains:** Ansible role task file containing 1 named task(s): `Wait for all Argo CD deployments to become available`.
  - **Learn from it:** Learn role decomposition, idempotency, variables, handlers, and secret-safe bootstrap automation.

- **`infrastructure/ansible/roles/argocd_bootstrap/templates/values.yaml.j2`**
  - **Contains:** Jinja2 template that renders Argo CD Helm values from Ansible variables during bootstrap, keeping environment-specific options out of hard-coded tasks.
  - **Learn from it:** Learn role decomposition, idempotency, variables, handlers, and secret-safe bootstrap automation.

- **`infrastructure/ansible/roles/common/README.md`**
  - **Contains:** Documentation titled **Common Role**. Prepare Ubuntu hosts for platform installation. Main sections include `Purpose`, `Responsibilities`, `Variables`, `Dependencies`, `Example`.
  - **Learn from it:** Learn role decomposition, idempotency, variables, handlers, and secret-safe bootstrap automation.

- **`infrastructure/ansible/roles/common/defaults/main.yml`**
  - **Contains:** Ansible variable file. It defines 6 configurable key(s): `common_timezone`, `common_locale`, `common_packages`, `common_upgrade_packages`, `common_autoremove`, `common_autoclean`.
  - **Learn from it:** Learn role decomposition, idempotency, variables, handlers, and secret-safe bootstrap automation.

- **`infrastructure/ansible/roles/common/handlers/main.yml`**
  - **Contains:** YAML document containing 0 parsed document(s).
  - **Learn from it:** Learn role decomposition, idempotency, variables, handlers, and secret-safe bootstrap automation.

- **`infrastructure/ansible/roles/common/meta/main.yml`**
  - **Contains:** Ansible role metadata declaring role information, platform compatibility, tags, and/or role dependencies.
  - **Learn from it:** Learn role decomposition, idempotency, variables, handlers, and secret-safe bootstrap automation.

- **`infrastructure/ansible/roles/common/tasks/main.yml`**
  - **Contains:** Ansible role task file containing 9 named task(s): `Update apt package cache`, `Upgrade installed packages`, `Install common packages`, `Configure timezone`, `Generate locale`, `Configure default locale`, `Enable systemd-timesyncd`, `Remove unused packages`, `Clean package cache`.
  - **Learn from it:** Learn role decomposition, idempotency, variables, handlers, and secret-safe bootstrap automation.

- **`infrastructure/ansible/roles/k3s/defaults/main.yml`**
  - **Contains:** Ansible variable file. It defines 4 configurable key(s): `k3s_version`, `k3s_install_script_url`, `k3s_install_script_path`, `k3s_install_args`.
  - **Learn from it:** Learn role decomposition, idempotency, variables, handlers, and secret-safe bootstrap automation.

- **`infrastructure/ansible/roles/k3s/handlers/main.yml`**
  - **Contains:** Ansible handlers file defining: `Restart k3s`.
  - **Learn from it:** Learn role decomposition, idempotency, variables, handlers, and secret-safe bootstrap automation.

- **`infrastructure/ansible/roles/k3s/meta/main.yml`**
  - **Contains:** Ansible role metadata declaring role information, platform compatibility, tags, and/or role dependencies.
  - **Learn from it:** Learn role decomposition, idempotency, variables, handlers, and secret-safe bootstrap automation.

- **`infrastructure/ansible/roles/k3s/tasks/main.yml`**
  - **Contains:** Ansible role task file containing 5 named task(s): `Check whether the requested k3s version is installed`, `Download the version-pinned k3s installer`, `Install the requested k3s version`, `Ensure k3s is enabled and running`, `Wait for the local Kubernetes API`.
  - **Learn from it:** Learn role decomposition, idempotency, variables, handlers, and secret-safe bootstrap automation.

- **`infrastructure/ansible/roles/kernel/defaults/main.yml`**
  - **Contains:** Ansible variable file. It defines 2 configurable key(s): `kernel_modules`, `kernel_sysctl_settings`.
  - **Learn from it:** Learn role decomposition, idempotency, variables, handlers, and secret-safe bootstrap automation.

- **`infrastructure/ansible/roles/kernel/meta/main.yml`**
  - **Contains:** Ansible role metadata declaring role information, platform compatibility, tags, and/or role dependencies.
  - **Learn from it:** Learn role decomposition, idempotency, variables, handlers, and secret-safe bootstrap automation.

- **`infrastructure/ansible/roles/kernel/tasks/main.yml`**
  - **Contains:** Ansible role task file containing 2 named task(s): `Load Kubernetes kernel modules persistently`, `Configure Kubernetes network sysctls`.
  - **Learn from it:** Learn role decomposition, idempotency, variables, handlers, and secret-safe bootstrap automation.

- **`infrastructure/ansible/roles/kubectl/meta/main.yml`**
  - **Contains:** Ansible role metadata declaring role information, platform compatibility, tags, and/or role dependencies.
  - **Learn from it:** Learn role decomposition, idempotency, variables, handlers, and secret-safe bootstrap automation.

- **`infrastructure/ansible/roles/kubectl/tasks/main.yml`**
  - **Contains:** Ansible role task file containing 6 named task(s): `Resolve platform administrator home directory`, `Set platform administrator home`, `Ensure kubeconfig directory exists`, `Copy k3s kubeconfig for the platform administrator`, `Configure the reachable Kubernetes API endpoint`, `Verify kubectl connectivity as the platform administrator`.
  - **Learn from it:** Learn role decomposition, idempotency, variables, handlers, and secret-safe bootstrap automation.

- **`infrastructure/ansible/roles/ssh/tasks/main.yml`**
  - **Contains:** Ansible role task file containing 1 named task(s): `Ensure OpenSSH server is installed`.
  - **Learn from it:** Learn role decomposition, idempotency, variables, handlers, and secret-safe bootstrap automation.

- **`infrastructure/ansible/roles/timesync/meta/main.yml`**
  - **Contains:** Ansible role metadata declaring role information, platform compatibility, tags, and/or role dependencies.
  - **Learn from it:** Learn role decomposition, idempotency, variables, handlers, and secret-safe bootstrap automation.

- **`infrastructure/ansible/roles/timesync/tasks/main.yml`**
  - **Contains:** Ansible role task file containing 2 named task(s): `Ensure systemd-timesyncd is installed`, `Ensure systemd-timesyncd is enabled and running`.
  - **Learn from it:** Learn role decomposition, idempotency, variables, handlers, and secret-safe bootstrap automation.

- **`infrastructure/ansible/roles/users/README.md`**
  - **Contains:** Documentation titled **Users Role**. Creates and manages the platform automation user. Main sections include `Variables`, `Dependencies`.
  - **Learn from it:** Learn role decomposition, idempotency, variables, handlers, and secret-safe bootstrap automation.

- **`infrastructure/ansible/roles/users/defaults/main.yml`**
  - **Contains:** Ansible variable file. It defines 7 configurable key(s): `users_name`, `users_group`, `users_shell`, `users_home`, `users_create_home`, `users_sudo`, `users_authorized_keys`.
  - **Learn from it:** Learn role decomposition, idempotency, variables, handlers, and secret-safe bootstrap automation.

- **`infrastructure/ansible/roles/users/handlers/main.yml`**
  - **Contains:** YAML document containing 0 parsed document(s).
  - **Learn from it:** Learn role decomposition, idempotency, variables, handlers, and secret-safe bootstrap automation.

- **`infrastructure/ansible/roles/users/meta/main.yml`**
  - **Contains:** Ansible role metadata declaring role information, platform compatibility, tags, and/or role dependencies.
  - **Learn from it:** Learn role decomposition, idempotency, variables, handlers, and secret-safe bootstrap automation.

- **`infrastructure/ansible/roles/users/tasks/main.yml`**
  - **Contains:** Ansible role task file containing 7 named task(s): `Create platform group`, `Create platform user`, `Configure passwordless sudo`, `Create .ssh directory`, `Configure authorized keys`, `Verify platform user exists`, `Assert platform user exists`.
  - **Learn from it:** Learn role decomposition, idempotency, variables, handlers, and secret-safe bootstrap automation.

### `infrastructure/bootstrap`

- **`infrastructure/bootstrap/bootstrap.sh`**
  - **Contains:** Operator entry point for preparing dependencies and invoking infrastructure/bootstrap automation.
  - **Learn from it:** Learn the repository-wide engineering convention represented by this file.

### `infrastructure/terraform`

- **`infrastructure/terraform/providers.tf`**
  - **Contains:** Terraform configuration declaring `provider local`, `provider null`.
  - **Learn from it:** Learn the declarative infrastructure boundary and version pinning expected before adding provider-specific resources.

- **`infrastructure/terraform/versions.tf`**
  - **Contains:** Terraform configuration declaring `terraform`.
  - **Learn from it:** Learn the declarative infrastructure boundary and version pinning expected before adding provider-specific resources.

### `infrastructure/validation`

- **`infrastructure/validation/validate.sh`**
  - **Contains:** Validates infrastructure prerequisites and configuration before deployment.
  - **Learn from it:** Learn the repository-wide engineering convention represented by this file.

## `platform-services`

Per-capability Helm values and supporting configuration for Backstage, networking, security, secrets, policy, and observability.

### `platform-services/backstage`

- **`platform-services/backstage/CAPABILITY-STATUS.md`**
  - **Contains:** Documentation titled **Backstage Capability Status**. It records project guidance and reference information.
  - **Learn from it:** Learn the difference between Helm configuration/catalog metadata and a custom Backstage image containing frontend/backend plugins.

- **`platform-services/backstage/CUSTOM-IMAGE-SPEC.md`**
  - **Contains:** Documentation titled **Custom Backstage Image Specification**. Define the minimum application-source work required before TuskerBlueprint can present embedded operational plugins as implemented. Main sections include `Purpose`, `Required modules`, `Image controls`, `Integration credentials`.
  - **Learn from it:** Learn the difference between Helm configuration/catalog metadata and a custom Backstage image containing frontend/backend plugins.

- **`platform-services/backstage/README.md`**
  - **Contains:** Documentation titled **Backstage**. Backstage is the developer discovery layer for TuskerBlueprint. The supported public demo registers the platform and `demo-service` catalog entities, provides ownership and TechDocs metadata, and links users to Git and Argo CD. Main sections include `Deployment model`, `Important plugin boundary`, `Catalog registration`, `Local access`.
  - **Learn from it:** Learn the difference between Helm configuration/catalog metadata and a custom Backstage image containing frontend/backend plugins.

- **`platform-services/backstage/app-config/app-config.development.yaml`**
  - **Contains:** YAML configuration with top-level keys: `app`, `organization`, `backend`, `techdocs`, `catalog`, `auth`.
  - **Learn from it:** Learn the difference between Helm configuration/catalog metadata and a custom Backstage image containing frontend/backend plugins.

- **`platform-services/backstage/values/development.yaml`**
  - **Contains:** Environment-specific Helm values for **backstage** in **development**. Top-level settings: `backstage`, `serviceAccount`, `ingress`. Notable switches: ingress.enabled=False.
  - **Learn from it:** Learn the difference between Helm configuration/catalog metadata and a custom Backstage image containing frontend/backend plugins.

- **`platform-services/backstage/values/production.yaml`**
  - **Contains:** Environment-specific Helm values for **backstage** in **production**. Top-level settings: `backstage`, `serviceAccount`, `ingress`. Notable switches: ingress.enabled=False.
  - **Learn from it:** Learn the difference between Helm configuration/catalog metadata and a custom Backstage image containing frontend/backend plugins.

- **`platform-services/backstage/values/staging.yaml`**
  - **Contains:** Environment-specific Helm values for **backstage** in **staging**. Top-level settings: `backstage`, `serviceAccount`, `ingress`. Notable switches: ingress.enabled=False.
  - **Learn from it:** Learn the difference between Helm configuration/catalog metadata and a custom Backstage image containing frontend/backend plugins.

### `platform-services/cert-manager`

- **`platform-services/cert-manager/CHANGELOG.md`**
  - **Contains:** Documentation titled **Changelog**. It records project guidance and reference information. Main sections include `0.1.0`, `Added`.
  - **Learn from it:** Compare development, staging, and production values to understand promotion, capacity, exposure, persistence, and security trade-offs.

- **`platform-services/cert-manager/README.md`**
  - **Contains:** Documentation titled **cert-manager**. cert-manager provides certificate lifecycle automation for the TuskerBlueprint platform. Main sections include `Purpose`, `Ownership`, `Architecture`, `Configuration`, `Validation`, `1. Confirm the Argo CD Applications are healthy`.
  - **Learn from it:** Compare development, staging, and production values to understand promotion, capacity, exposure, persistence, and security trade-offs.

- **`platform-services/cert-manager/values/development.yaml`**
  - **Contains:** Environment-specific Helm values for **cert-manager** in **development**. Top-level settings: `crds`, `installCRDs`, `replicaCount`, `global`, `resources`, `containerSecurityContext`. Notable switches: replicaCount=1, installCRDs=False.
  - **Learn from it:** Compare development, staging, and production values to understand promotion, capacity, exposure, persistence, and security trade-offs.

- **`platform-services/cert-manager/values/production.yaml`**
  - **Contains:** Environment-specific Helm values for **cert-manager** in **production**. Top-level settings: `crds`, `installCRDs`, `replicaCount`, `global`, `resources`, `containerSecurityContext`. Notable switches: replicaCount=1, installCRDs=False.
  - **Learn from it:** Compare development, staging, and production values to understand promotion, capacity, exposure, persistence, and security trade-offs.

- **`platform-services/cert-manager/values/staging.yaml`**
  - **Contains:** Environment-specific Helm values for **cert-manager** in **staging**. Top-level settings: `crds`, `installCRDs`, `replicaCount`, `global`, `resources`, `containerSecurityContext`. Notable switches: replicaCount=1, installCRDs=False.
  - **Learn from it:** Compare development, staging, and production values to understand promotion, capacity, exposure, persistence, and security trade-offs.

### `platform-services/doppler`

- **`platform-services/doppler/README.md`**
  - **Contains:** Documentation titled **Doppler**. Doppler provides a centralized secret-management integration layer for platform workloads and applications. Main sections include `Purpose`, `Ownership`, `Notes`.
  - **Learn from it:** Compare development, staging, and production values to understand promotion, capacity, exposure, persistence, and security trade-offs.

- **`platform-services/doppler/values/development.yaml`**
  - **Contains:** Environment-specific Helm values for **doppler** in **development**. Top-level settings: `replicaCount`, `serviceAccount`, `resources`. Notable switches: replicaCount=1.
  - **Learn from it:** Compare development, staging, and production values to understand promotion, capacity, exposure, persistence, and security trade-offs.

- **`platform-services/doppler/values/production.yaml`**
  - **Contains:** Environment-specific Helm values for **doppler** in **production**. Top-level settings: `replicaCount`, `serviceAccount`, `resources`. Notable switches: replicaCount=1.
  - **Learn from it:** Compare development, staging, and production values to understand promotion, capacity, exposure, persistence, and security trade-offs.

- **`platform-services/doppler/values/staging.yaml`**
  - **Contains:** Environment-specific Helm values for **doppler** in **staging**. Top-level settings: `replicaCount`, `serviceAccount`, `resources`. Notable switches: replicaCount=1.
  - **Learn from it:** Compare development, staging, and production values to understand promotion, capacity, exposure, persistence, and security trade-offs.

### `platform-services/external-secrets`

- **`platform-services/external-secrets/README.md`**
  - **Contains:** Documentation titled **External Secrets Operator**. External Secrets Operator provides a secure way to synchronize secrets from external secret backends into Kubernetes. Main sections include `Purpose`, `Ownership`, `Notes`.
  - **Learn from it:** Compare development, staging, and production values to understand promotion, capacity, exposure, persistence, and security trade-offs.

- **`platform-services/external-secrets/examples/README.md`**
  - **Contains:** Documentation titled **External Secret Examples**. These manifests show the contract between workloads and a pre-provisioned `ClusterSecretStore` named `platform-secret-store`. They contain no secret value and are not included in an environment Kustomization because the provider, authentication method, remote paths, and namespaces are customer-specific.
  - **Learn from it:** Compare development, staging, and production values to understand promotion, capacity, exposure, persistence, and security trade-offs.

- **`platform-services/external-secrets/examples/backstage-external-secret.yaml`**
  - **Contains:** External Secrets resource `ExternalSecret/backstage-secrets` describing how remote secret values are synchronized into Kubernetes without committing the values.
  - **Learn from it:** Compare development, staging, and production values to understand promotion, capacity, exposure, persistence, and security trade-offs.

- **`platform-services/external-secrets/examples/grafana-external-secret.yaml`**
  - **Contains:** External Secrets resource `ExternalSecret/grafana-admin` describing how remote secret values are synchronized into Kubernetes without committing the values.
  - **Learn from it:** Compare development, staging, and production values to understand promotion, capacity, exposure, persistence, and security trade-offs.

- **`platform-services/external-secrets/values/development.yaml`**
  - **Contains:** Environment-specific Helm values for **external-secrets** in **development**. Top-level settings: `replicaCount`, `serviceAccount`, `resources`. Notable switches: replicaCount=1.
  - **Learn from it:** Compare development, staging, and production values to understand promotion, capacity, exposure, persistence, and security trade-offs.

- **`platform-services/external-secrets/values/production.yaml`**
  - **Contains:** Environment-specific Helm values for **external-secrets** in **production**. Top-level settings: `replicaCount`, `serviceAccount`, `resources`. Notable switches: replicaCount=1.
  - **Learn from it:** Compare development, staging, and production values to understand promotion, capacity, exposure, persistence, and security trade-offs.

- **`platform-services/external-secrets/values/staging.yaml`**
  - **Contains:** Environment-specific Helm values for **external-secrets** in **staging**. Top-level settings: `replicaCount`, `serviceAccount`, `resources`. Notable switches: replicaCount=1.
  - **Learn from it:** Compare development, staging, and production values to understand promotion, capacity, exposure, persistence, and security trade-offs.

### `platform-services/grafana`

- **`platform-services/grafana/README.md`**
  - **Contains:** Documentation titled **Grafana**. Grafana provides dashboards and visualization for the TuskerBlueprint platform. Main sections include `Purpose`, `Ownership`, `Notes`.
  - **Learn from it:** Compare development, staging, and production values to understand promotion, capacity, exposure, persistence, and security trade-offs.

- **`platform-services/grafana/values/development.yaml`**
  - **Contains:** Environment-specific Helm values for **grafana** in **development**. Top-level settings: `adminUser`, `service`, `persistence`, `resources`, `datasources`, `grafana.ini`. Notable switches: persistence.enabled=False.
  - **Learn from it:** Compare development, staging, and production values to understand promotion, capacity, exposure, persistence, and security trade-offs.

- **`platform-services/grafana/values/production.yaml`**
  - **Contains:** Environment-specific Helm values for **grafana** in **production**. Top-level settings: `adminUser`, `service`, `persistence`, `resources`, `datasources`, `grafana.ini`. Notable switches: persistence.enabled=True.
  - **Learn from it:** Compare development, staging, and production values to understand promotion, capacity, exposure, persistence, and security trade-offs.

- **`platform-services/grafana/values/staging.yaml`**
  - **Contains:** Environment-specific Helm values for **grafana** in **staging**. Top-level settings: `adminUser`, `service`, `persistence`, `resources`, `datasources`, `grafana.ini`. Notable switches: persistence.enabled=True.
  - **Learn from it:** Compare development, staging, and production values to understand promotion, capacity, exposure, persistence, and security trade-offs.

### `platform-services/kyverno`

- **`platform-services/kyverno/README.md`**
  - **Contains:** Documentation titled **Kyverno**. Kyverno provides policy validation and reporting for TuskerBlueprint workloads. The chart installs the controllers; policy resources are reconciled by a separate Argo CD Application after the controllers become healthy. Main sections include `Enforcement progression`, `Validation`.
  - **Learn from it:** Compare development, staging, and production values to understand promotion, capacity, exposure, persistence, and security trade-offs.

- **`platform-services/kyverno/policies/base/kustomization.yaml`**
  - **Contains:** Kustomize composition listing 1 resource(s). Resources: `workload-baseline.yaml`. Additional behavior: plain composition only.
  - **Learn from it:** Learn how policy-as-code moves from audit in lower environments to enforcement in production.

- **`platform-services/kyverno/policies/base/workload-baseline.yaml`**
  - **Contains:** Kyverno `ClusterPolicy` **tuskerblueprint-workload-baseline** with validation action `Audit` and rules `require-standard-labels`, `disallow-floating-image-tags`, `require-resources-and-probes`, `require-restricted-container-security`.
  - **Learn from it:** Learn how policy-as-code moves from audit in lower environments to enforcement in production.

- **`platform-services/kyverno/policies/overlays/development/kustomization.yaml`**
  - **Contains:** Kustomize composition listing 1 resource(s), and 1 patch(es). Resources: `../../base`. Additional behavior: plain composition only.
  - **Learn from it:** Learn how policy-as-code moves from audit in lower environments to enforcement in production.

- **`platform-services/kyverno/policies/overlays/production/kustomization.yaml`**
  - **Contains:** Kustomize composition listing 1 resource(s), and 1 patch(es). Resources: `../../base`. Additional behavior: plain composition only.
  - **Learn from it:** Learn how policy-as-code moves from audit in lower environments to enforcement in production.

- **`platform-services/kyverno/policies/overlays/staging/kustomization.yaml`**
  - **Contains:** Kustomize composition listing 1 resource(s), and 1 patch(es). Resources: `../../base`. Additional behavior: plain composition only.
  - **Learn from it:** Learn how policy-as-code moves from audit in lower environments to enforcement in production.

- **`platform-services/kyverno/values/development.yaml`**
  - **Contains:** Environment-specific Helm values for **kyverno** in **development**. Top-level settings: `crds`, `admissionController`, `backgroundController`, `reportsController`, `cleanupController`, `features`. Notable switches: review the nested chart settings for resources, security, persistence, and exposure.
  - **Learn from it:** Compare development, staging, and production values to understand promotion, capacity, exposure, persistence, and security trade-offs.

- **`platform-services/kyverno/values/production.yaml`**
  - **Contains:** Environment-specific Helm values for **kyverno** in **production**. Top-level settings: `crds`, `admissionController`, `backgroundController`, `reportsController`, `cleanupController`, `features`. Notable switches: review the nested chart settings for resources, security, persistence, and exposure.
  - **Learn from it:** Compare development, staging, and production values to understand promotion, capacity, exposure, persistence, and security trade-offs.

- **`platform-services/kyverno/values/staging.yaml`**
  - **Contains:** Environment-specific Helm values for **kyverno** in **staging**. Top-level settings: `crds`, `admissionController`, `backgroundController`, `reportsController`, `cleanupController`, `features`. Notable switches: review the nested chart settings for resources, security, persistence, and exposure.
  - **Learn from it:** Compare development, staging, and production values to understand promotion, capacity, exposure, persistence, and security trade-offs.

### `platform-services/loki`

- **`platform-services/loki/README.md`**
  - **Contains:** Documentation titled **Loki**. Loki provides log aggregation for the TuskerBlueprint platform. Main sections include `Purpose`, `Ownership`, `Notes`.
  - **Learn from it:** Compare development, staging, and production values to understand promotion, capacity, exposure, persistence, and security trade-offs.

- **`platform-services/loki/values/development.yaml`**
  - **Contains:** Environment-specific Helm values for **loki** in **development**. Top-level settings: `deploymentMode`, `loki`, `singleBinary`, `read`, `write`, `backend`, `gateway`, `test`. Notable switches: review the nested chart settings for resources, security, persistence, and exposure.
  - **Learn from it:** Compare development, staging, and production values to understand promotion, capacity, exposure, persistence, and security trade-offs.

- **`platform-services/loki/values/production.yaml`**
  - **Contains:** Environment-specific Helm values for **loki** in **production**. Top-level settings: `deploymentMode`, `loki`, `singleBinary`, `read`, `write`, `backend`, `gateway`, `test`. Notable switches: review the nested chart settings for resources, security, persistence, and exposure.
  - **Learn from it:** Compare development, staging, and production values to understand promotion, capacity, exposure, persistence, and security trade-offs.

- **`platform-services/loki/values/staging.yaml`**
  - **Contains:** Environment-specific Helm values for **loki** in **staging**. Top-level settings: `deploymentMode`, `loki`, `singleBinary`, `read`, `write`, `backend`, `gateway`, `test`. Notable switches: review the nested chart settings for resources, security, persistence, and exposure.
  - **Learn from it:** Compare development, staging, and production values to understand promotion, capacity, exposure, persistence, and security trade-offs.

### `platform-services/prometheus`

- **`platform-services/prometheus/README.md`**
  - **Contains:** Documentation titled **Prometheus**. Prometheus provides metrics collection and alerting for the TuskerBlueprint platform. Main sections include `Purpose`, `Ownership`, `Notes`.
  - **Learn from it:** Compare development, staging, and production values to understand promotion, capacity, exposure, persistence, and security trade-offs.

- **`platform-services/prometheus/values/development.yaml`**
  - **Contains:** Environment-specific Helm values for **prometheus** in **development**. Top-level settings: `server`, `alertmanager`, `pushgateway`, `kube-state-metrics`, `prometheus-node-exporter`. Notable switches: review the nested chart settings for resources, security, persistence, and exposure.
  - **Learn from it:** Compare development, staging, and production values to understand promotion, capacity, exposure, persistence, and security trade-offs.

- **`platform-services/prometheus/values/production.yaml`**
  - **Contains:** Environment-specific Helm values for **prometheus** in **production**. Top-level settings: `server`, `alertmanager`, `pushgateway`, `kube-state-metrics`, `prometheus-node-exporter`. Notable switches: review the nested chart settings for resources, security, persistence, and exposure.
  - **Learn from it:** Compare development, staging, and production values to understand promotion, capacity, exposure, persistence, and security trade-offs.

- **`platform-services/prometheus/values/staging.yaml`**
  - **Contains:** Environment-specific Helm values for **prometheus** in **staging**. Top-level settings: `server`, `alertmanager`, `pushgateway`, `kube-state-metrics`, `prometheus-node-exporter`. Notable switches: review the nested chart settings for resources, security, persistence, and exposure.
  - **Learn from it:** Compare development, staging, and production values to understand promotion, capacity, exposure, persistence, and security trade-offs.

### `platform-services/traefik`

- **`platform-services/traefik/CHANGELOG.md`**
  - **Contains:** Documentation titled **Changelog**. It records project guidance and reference information. Main sections include `0.2.0`, `Added`, `0.1.0`, `Added`.
  - **Learn from it:** Compare development, staging, and production values to understand promotion, capacity, exposure, persistence, and security trade-offs.

- **`platform-services/traefik/README.md`**
  - **Contains:** Documentation titled **Traefik**. Traefik provides the ingress controller and edge routing layer for the TuskerBlueprint platform. Main sections include `Purpose`, `Ownership`, `Architecture`, `Configuration`, `Validation`, `1. Confirm the Argo CD Application is healthy`.
  - **Learn from it:** Compare development, staging, and production values to understand promotion, capacity, exposure, persistence, and security trade-offs.

- **`platform-services/traefik/values/development.yaml`**
  - **Contains:** Environment-specific Helm values for **traefik** in **development**. Top-level settings: `deployment`, `nameOverride`, `fullnameOverride`, `ingressClass`, `providers`, `logs`, `accessLog`, `metrics`, `dashboard`, `ports`, `service`, `additionalArguments`, `globalArguments`, `resources`, `podSecurityContext`, `securityContext`…. Notable switches: persistence.enabled=False.
  - **Learn from it:** Compare development, staging, and production values to understand promotion, capacity, exposure, persistence, and security trade-offs.

- **`platform-services/traefik/values/production.yaml`**
  - **Contains:** Environment-specific Helm values for **traefik** in **production**. Top-level settings: `deployment`, `nameOverride`, `fullnameOverride`, `ingressClass`, `providers`, `logs`, `accessLog`, `metrics`, `dashboard`, `service`, `resources`, `podSecurityContext`, `securityContext`. Notable switches: review the nested chart settings for resources, security, persistence, and exposure.
  - **Learn from it:** Compare development, staging, and production values to understand promotion, capacity, exposure, persistence, and security trade-offs.

- **`platform-services/traefik/values/staging.yaml`**
  - **Contains:** Environment-specific Helm values for **traefik** in **staging**. Top-level settings: `deployment`, `nameOverride`, `fullnameOverride`, `ingressClass`, `providers`, `logs`, `accessLog`, `metrics`, `dashboard`, `service`, `resources`, `podSecurityContext`, `securityContext`. Notable switches: review the nested chart settings for resources, security, persistence, and exposure.
  - **Learn from it:** Compare development, staging, and production values to understand promotion, capacity, exposure, persistence, and security trade-offs.

## `workloads`

The sample product workload used to demonstrate secure Kubernetes defaults, GitOps reconciliation, Backstage registration, and environment promotion.

### `workloads/demo-service`

- **`workloads/demo-service/base/content/index.html`**
  - **Contains:** Static HTML content served by the demo workload. The page title/main heading is **TuskerBlueprint Demo Service**, making release changes visible during the GitOps demo.
  - **Learn from it:** Learn the reusable security and reliability baseline for a Kubernetes workload.

- **`workloads/demo-service/base/deployment.yaml`**
  - **Contains:** Kubernetes `Deployment` **demo-service** with 2 replica(s), image(s) `nginxinc/nginx-unprivileged:1.27-alpine`, rolling-update and hardened pod/container settings.
  - **Learn from it:** Learn the reusable security and reliability baseline for a Kubernetes workload.

- **`workloads/demo-service/base/kustomization.yaml`**
  - **Contains:** Kustomize composition listing 5 resource(s). Resources: `service-account.yaml`, `deployment.yaml`, `service.yaml`, `pod-disruption-budget.yaml`, `network-policy.yaml`. Additional behavior: shared labels, configMapGenerator:demo-service-content.
  - **Learn from it:** Learn the reusable security and reliability baseline for a Kubernetes workload.

- **`workloads/demo-service/base/network-policy.yaml`**
  - **Contains:** Kubernetes `NetworkPolicy` **demo-service-default-deny** controlling Ingress, Egress traffic. Kubernetes `NetworkPolicy` **demo-service-allow-ingress** controlling Ingress traffic.
  - **Learn from it:** Learn the reusable security and reliability baseline for a Kubernetes workload.

- **`workloads/demo-service/base/pod-disruption-budget.yaml`**
  - **Contains:** Kubernetes `PodDisruptionBudget` **demo-service** preserving availability with minAvailable=1 and maxUnavailable=n/a.
  - **Learn from it:** Learn the reusable security and reliability baseline for a Kubernetes workload.

- **`workloads/demo-service/base/service-account.yaml`**
  - **Contains:** Dedicated Kubernetes `ServiceAccount` **demo-service** for workload identity separation.
  - **Learn from it:** Learn the reusable security and reliability baseline for a Kubernetes workload.

- **`workloads/demo-service/base/service.yaml`**
  - **Contains:** Kubernetes `Service` **demo-service** exposing 80→http.
  - **Learn from it:** Learn the reusable security and reliability baseline for a Kubernetes workload.

- **`workloads/demo-service/catalog-info.yaml`**
  - **Contains:** Backstage catalog manifest defining 1 entity/entities: `Component/demo-service`.
  - **Learn from it:** Learn how application runtime manifests, catalog metadata, and documentation form one product-owned unit.

- **`workloads/demo-service/docs/index.md`**
  - **Contains:** Documentation titled **TuskerBlueprint Demo Service**. The demo service is a deliberately small HTTP workload used to show Git-driven release, Argo CD reconciliation, Kubernetes health, drift correction, Backstage ownership, and security controls. Main sections include `Ownership`, `Release`, `Runtime`, `Rollback`.
  - **Learn from it:** Learn how application runtime manifests, catalog metadata, and documentation form one product-owned unit.

- **`workloads/demo-service/mkdocs.yml`**
  - **Contains:** YAML configuration with top-level keys: `site_name`, `nav`.
  - **Learn from it:** Learn how application runtime manifests, catalog metadata, and documentation form one product-owned unit.

- **`workloads/demo-service/overlays/development/kustomization.yaml`**
  - **Contains:** Kustomize composition listing 1 resource(s). Resources: `../../base`. Additional behavior: namespace `demo-development`, shared labels.
  - **Learn from it:** Learn how environment overlays change only what differs while inheriting a common workload base.

- **`workloads/demo-service/overlays/production/kustomization.yaml`**
  - **Contains:** Kustomize composition listing 1 resource(s). Resources: `../../base`. Additional behavior: namespace `demo-production`, shared labels.
  - **Learn from it:** Learn how environment overlays change only what differs while inheriting a common workload base.

- **`workloads/demo-service/overlays/staging/kustomization.yaml`**
  - **Contains:** Kustomize composition listing 1 resource(s). Resources: `../../base`. Additional behavior: namespace `demo-staging`, shared labels.
  - **Learn from it:** Learn how environment overlays change only what differs while inheriting a common workload base.

## `scripts`

Executable validation, verification, demonstration, and release automation.

### `scripts/ci`

- **`scripts/ci/__pycache__/repository_policy.cpython-313.pyc`**
  - **Contains:** Generated CPython bytecode cache for `repository_policy.py`. It contains compiled interpreter instructions, is machine/version specific, and is not human-maintained source.
  - **Learn from it:** This is generated bytecode, not learning source. Remove it and add `__pycache__/` and `*.pyc` to `.gitignore` before publishing.

- **`scripts/ci/__pycache__/validate_catalog.cpython-313.pyc`**
  - **Contains:** Generated CPython bytecode cache for `validate_catalog.py`. It contains compiled interpreter instructions, is machine/version specific, and is not human-maintained source.
  - **Learn from it:** This is generated bytecode, not learning source. Remove it and add `__pycache__/` and `*.pyc` to `.gitignore` before publishing.

- **`scripts/ci/__pycache__/validate_kustomizations.cpython-313.pyc`**
  - **Contains:** Generated CPython bytecode cache for `validate_kustomizations.py`. It contains compiled interpreter instructions, is machine/version specific, and is not human-maintained source.
  - **Learn from it:** This is generated bytecode, not learning source. Remove it and add `__pycache__/` and `*.pyc` to `.gitignore` before publishing.

- **`scripts/ci/__pycache__/validate_markdown_links.cpython-313.pyc`**
  - **Contains:** Generated CPython bytecode cache for `validate_markdown_links.py`. It contains compiled interpreter instructions, is machine/version specific, and is not human-maintained source.
  - **Learn from it:** This is generated bytecode, not learning source. Remove it and add `__pycache__/` and `*.pyc` to `.gitignore` before publishing.

- **`scripts/ci/__pycache__/validate_yaml.cpython-313.pyc`**
  - **Contains:** Generated CPython bytecode cache for `validate_yaml.py`. It contains compiled interpreter instructions, is machine/version specific, and is not human-maintained source.
  - **Learn from it:** This is generated bytecode, not learning source. Remove it and add `__pycache__/` and `*.pyc` to `.gitignore` before publishing.

- **`scripts/ci/render_kustomize.sh`**
  - **Contains:** Renders environment Kustomizations when kubectl or kustomize is available, catching composition errors. It defines functions `render`.
  - **Learn from it:** Learn how custom policy checks close gaps not covered by generic linters.

- **`scripts/ci/repository_policy.py`**
  - **Contains:** Enforce public-repository and Kubernetes safety policy. It contains functions `files`, `is_public_ip`, `walk_images`, `main`.
  - **Learn from it:** Learn how custom policy checks close gaps not covered by generic linters.

- **`scripts/ci/secret_scan.sh`**
  - **Contains:** Runs repository secret scanning and fallback pattern checks.
  - **Learn from it:** Learn how custom policy checks close gaps not covered by generic linters.

- **`scripts/ci/validate_all.sh`**
  - **Contains:** Executes the full local validation, security, Terraform, and Ansible checks.
  - **Learn from it:** Learn how custom policy checks close gaps not covered by generic linters.

- **`scripts/ci/validate_catalog.py`**
  - **Contains:** Validate required TuskerBlueprint Backstage entities. It contains functions `docs`, `main`.
  - **Learn from it:** Learn how custom policy checks close gaps not covered by generic linters.

- **`scripts/ci/validate_kustomizations.py`**
  - **Contains:** Validate Kustomize resource references and duplicate rendered identities. It contains classes `Identity`, and functions `load_yaml_documents`, `find_kustomization`, `collect`, `validate_all_references`, `main`.
  - **Learn from it:** Learn how custom policy checks close gaps not covered by generic linters.

- **`scripts/ci/validate_markdown_links.py`**
  - **Contains:** Check local Markdown links without network access. It contains functions `main`.
  - **Learn from it:** Learn how custom policy checks close gaps not covered by generic linters.

- **`scripts/ci/validate_shell.sh`**
  - **Contains:** Checks Bash syntax for shell files and runs ShellCheck when installed.
  - **Learn from it:** Learn how custom policy checks close gaps not covered by generic linters.

- **`scripts/ci/validate_yaml.py`**
  - **Contains:** Parse all repository YAML and reject duplicate mapping keys. It contains classes `UniqueKeyLoader`, and functions `construct_mapping`, `candidates`, `main`.
  - **Learn from it:** Learn how custom policy checks close gaps not covered by generic linters.

### `scripts/demo`

- **`scripts/demo/introduce-drift.sh`**
  - **Contains:** Deliberately changes the live demo workload to demonstrate Argo CD self-healing.
  - **Learn from it:** Learn how to make a customer demonstration deterministic, observable, reversible, and safe.

- **`scripts/demo/preflight.sh`**
  - **Contains:** Checks repository and development-cluster readiness before a customer demonstration.
  - **Learn from it:** Learn how to make a customer demonstration deterministic, observable, reversible, and safe.

- **`scripts/demo/rollback-status.sh`**
  - **Contains:** Shows rollout and revision information used in the rollback portion of the demo.
  - **Learn from it:** Learn how to make a customer demonstration deterministic, observable, reversible, and safe.

- **`scripts/demo/status.sh`**
  - **Contains:** Prints current Argo CD, Kubernetes, and demo-service status for the presenter.
  - **Learn from it:** Learn how to make a customer demonstration deterministic, observable, reversible, and safe.

### `scripts/platform-verification`

- **`scripts/platform-verification/README.md`**
  - **Contains:** Documentation titled **TuskerBlueprint Platform Verification Framework (TPVF)**. The TuskerBlueprint Platform Verification Framework (TPVF) provides a standardized mechanism for validating, verifying, auditing, and assessing the operational readiness of the TuskerBlueprint Platform. Main sections include `Overview`, `Design Goals`, `Framework Architecture`, `Verification Philosophy`, `Verification Profiles`, `Smoke`.
  - **Learn from it:** Learn how to verify actual platform behavior rather than only validating static manifests.

- **`scripts/platform-verification/developer-platform/verify-backstage.sh`**
  - **Contains:** Verify the Backstage capability. shellcheck shell=bash ==============================================================================
  - **Learn from it:** Learn how to verify actual platform behavior rather than only validating static manifests.

- **`scripts/platform-verification/lib/argocd-api.sh`**
  - **Contains:** Thin wrapper around Kubernetes for Argo CD resources. Responsibilities: - Query Argo CD Applications - Query AppProjects - Return normalized results This library never prints output and never exits. shellcheck shell=bash ============================================================================== It defines functions `application_exists`, `application_synced`, `application_healthy`, `project_exists`, `repository_registered`.
  - **Learn from it:** Learn framework design: reusable API, state, execution, reporting, and assertion libraries keep component checks consistent.

- **`scripts/platform-verification/lib/bootstrap.sh`**
  - **Contains:** Provides reusable `bootstrap` library functions for the platform verification framework. It defines functions `cleanup`, `bootstrap_framework`.
  - **Learn from it:** Learn framework design: reusable API, state, execution, reporting, and assertion libraries keep component checks consistent.

- **`scripts/platform-verification/lib/checks/argocd.sh`**
  - **Contains:** Argo CD verification checks. Responsibilities: - Evaluate Argo CD state - Return success/failure only shellcheck shell=bash ============================================================================== It defines functions `check_application`, `check_application_synced`, `check_application_healthy`, `check_project`, `check_repository`.
  - **Learn from it:** Learn framework design: reusable API, state, execution, reporting, and assertion libraries keep component checks consistent.

- **`scripts/platform-verification/lib/checks/kubernetes.sh`**
  - **Contains:** Kubernetes verification checks. Responsibilities: - Evaluate Kubernetes resource state - Return success/failure only No output. No colours. No exits. shellcheck shell=bash ============================================================================== It defines functions `check_namespace`, `check_deployment`, `check_deployment_ready`, `check_daemonset`, `check_statefulset`, `check_service`, `check_pods`, `check_ingress`, `check_ingressclass`, `check_configmap`, `check_secret`, `check_crd`….
  - **Learn from it:** Learn framework design: reusable API, state, execution, reporting, and assertion libraries keep component checks consistent.

- **`scripts/platform-verification/lib/common.sh`**
  - **Contains:** Generic Bash helper functions shared across the verification framework. Responsibilities: - Command helpers - File and directory helpers - String helpers - Retry helpers - Timing helpers - Generic error handling This library intentionally contains NO platform-specific logic. It MUST NOT reference: - Kubernetes - Argo CD - Helm - GitHub - Verification logic… It defines functions `command_exists`, `require_command`, `file_exists`, `directory_exists`, `require_file`, `require_directory`, `is_empty`, `is_not_empty`, `join_by`, `retry`, `die`, `current_timestamp`….
  - **Learn from it:** Learn framework design: reusable API, state, execution, reporting, and assertion libraries keep component checks consistent.

- **`scripts/platform-verification/lib/constants.sh`**
  - **Contains:** Provides reusable `constants` library functions for the platform verification framework.
  - **Learn from it:** Learn framework design: reusable API, state, execution, reporting, and assertion libraries keep component checks consistent.

- **`scripts/platform-verification/lib/executor.sh`**
  - **Contains:** Centralized execution wrappers for external CLI tools. Responsibilities: - kubectl - helm - argocd - gh All API wrappers must use these functions. shellcheck shell=bash ============================================================================== It defines functions `kube`, `helm_exec`, `argo`, `gh_exec`.
  - **Learn from it:** Learn framework design: reusable API, state, execution, reporting, and assertion libraries keep component checks consistent.

- **`scripts/platform-verification/lib/kubernetes-api.sh`**
  - **Contains:** Thin wrapper around the Kubernetes API used by the verification framework. Responsibilities: - Execute Kubernetes API queries - Return normalized results - Never print output - Never exit the program Contract: - Never print PASS/FAIL - Never call exit - Never perform verification logic - Never format output - Return command exit status only All Kubernetes i… It defines functions `cluster_available`, `namespace_exists`, `deployment_exists`, `deployment_ready`, `daemonset_exists`, `statefulset_exists`, `pods_exist`, `service_exists`, `ingress_exists`, `ingressclass_exists`, `configmap_exists`, `secret_exists`….
  - **Learn from it:** Learn framework design: reusable API, state, execution, reporting, and assertion libraries keep component checks consistent.

- **`scripts/platform-verification/lib/output.sh`**
  - **Contains:** Provides reusable `output` library functions for the platform verification framework. It defines functions `_timestamp`, `_print`, `info`, `success`, `warning`, `error`, `debug`, `header`, `section`, `step`, `summary`, `banner`.
  - **Learn from it:** Learn framework design: reusable API, state, execution, reporting, and assertion libraries keep component checks consistent.

- **`scripts/platform-verification/lib/report.sh`**
  - **Contains:** Reporting utilities for verification execution. Responsibilities: - Verification summary - Execution statistics - Runtime information - Final framework exit status This library: - Never communicates with Kubernetes - Never performs verification - Never modifies runtime state shellcheck shell=bash =============================================================… It defines functions `print_summary`, `print_execution_time`, `print_final_report`, `framework_exit`.
  - **Learn from it:** Learn framework design: reusable API, state, execution, reporting, and assertion libraries keep component checks consistent.

- **`scripts/platform-verification/lib/runtime.sh`**
  - **Contains:** Provides reusable `runtime` library functions for the platform verification framework. It defines functions `validate_dependencies`, `validate_kubeconfig`, `validate_cluster`, `display_cluster_information`, `validate_runtime`.
  - **Learn from it:** Learn framework design: reusable API, state, execution, reporting, and assertion libraries keep component checks consistent.

- **`scripts/platform-verification/lib/state.sh`**
  - **Contains:** Maintains runtime execution state for the verification framework. Responsibilities: - Verification statistics - Execution metadata - Runtime context This library contains mutable runtime state only. shellcheck shell=bash ============================================================================== It defines functions `reset_verification_state`, `finish_execution`, `execution_duration`, `increment_total`, `increment_passed`, `increment_failed`, `increment_warning`, `increment_skipped`.
  - **Learn from it:** Learn framework design: reusable API, state, execution, reporting, and assertion libraries keep component checks consistent.

- **`scripts/platform-verification/lib/verifiers.sh`**
  - **Contains:** Verification engine and reusable verifier functions. Responsibilities: - Execute verification checks - Produce standardized PASS/FAIL output - Update verification statistics This library: - Never communicates directly with Kubernetes - Never communicates directly with Argo CD - Never generates reports Verification flow: Verifier ↓ Check ↓ API ↓ Executor ↓ C… It defines functions `run_verification`, `verify_namespace`, `verify_deployment`, `verify_deployment_ready`, `verify_daemonset`, `verify_statefulset`, `verify_service`, `verify_pods`, `verify_ingress`, `verify_ingressclass`, `verify_configmap`, `verify_secret`….
  - **Learn from it:** Learn framework design: reusable API, state, execution, reporting, and assertion libraries keep component checks consistent.

- **`scripts/platform-verification/networking/verify-traefik.sh`**
  - **Contains:** Verify the Traefik platform capability. Responsibilities: - Verify Argo CD application - Verify Kubernetes resources - Verify networking capability readiness shellcheck shell=bash ==============================================================================
  - **Learn from it:** Learn how to verify actual platform behavior rather than only validating static manifests.

- **`scripts/platform-verification/observability/verify-grafana.sh`**
  - **Contains:** Verify the Grafana capability. shellcheck shell=bash ==============================================================================
  - **Learn from it:** Learn how to verify actual platform behavior rather than only validating static manifests.

- **`scripts/platform-verification/observability/verify-loki.sh`**
  - **Contains:** Verify the Loki capability. shellcheck shell=bash ==============================================================================
  - **Learn from it:** Learn how to verify actual platform behavior rather than only validating static manifests.

- **`scripts/platform-verification/observability/verify-prometheus.sh`**
  - **Contains:** Verify the Prometheus capability. shellcheck shell=bash ==============================================================================
  - **Learn from it:** Learn how to verify actual platform behavior rather than only validating static manifests.

- **`scripts/platform-verification/profiles/audit.sh`**
  - **Contains:** Execute platform audit verification. shellcheck shell=bash ==============================================================================
  - **Learn from it:** Learn how verification depth is expressed as reusable profiles for smoke, regression, audit, and upgrades.

- **`scripts/platform-verification/profiles/e2e.sh`**
  - **Contains:** Execute end-to-end verification. shellcheck shell=bash ==============================================================================
  - **Learn from it:** Learn how verification depth is expressed as reusable profiles for smoke, regression, audit, and upgrades.

- **`scripts/platform-verification/profiles/platform.sh`**
  - **Contains:** Defines the `platform` verification profile by composing capability tests in the required order.
  - **Learn from it:** Learn how verification depth is expressed as reusable profiles for smoke, regression, audit, and upgrades.

- **`scripts/platform-verification/profiles/post-upgrade.sh`**
  - **Contains:** Execute verification after platform upgrades. shellcheck shell=bash ==============================================================================
  - **Learn from it:** Learn how verification depth is expressed as reusable profiles for smoke, regression, audit, and upgrades.

- **`scripts/platform-verification/profiles/pre-upgrade.sh`**
  - **Contains:** Execute verification before platform upgrades. shellcheck shell=bash ==============================================================================
  - **Learn from it:** Learn how verification depth is expressed as reusable profiles for smoke, regression, audit, and upgrades.

- **`scripts/platform-verification/profiles/regression.sh`**
  - **Contains:** Defines the `regression` verification profile by composing capability tests in the required order.
  - **Learn from it:** Learn how verification depth is expressed as reusable profiles for smoke, regression, audit, and upgrades.

- **`scripts/platform-verification/profiles/smoke.sh`**
  - **Contains:** Defines the `smoke` verification profile by composing capability tests in the required order.
  - **Learn from it:** Learn how verification depth is expressed as reusable profiles for smoke, regression, audit, and upgrades.

- **`scripts/platform-verification/security/verify-cert-manager.sh`**
  - **Contains:** Verify the cert-manager platform capability. Responsibilities: - Verify Argo CD application - Verify cert-manager Kubernetes resources - Verify cert-manager CRDs and API discovery shellcheck shell=bash ==============================================================================
  - **Learn from it:** Learn how to verify actual platform behavior rather than only validating static manifests.

- **`scripts/platform-verification/security/verify-doppler.sh`**
  - **Contains:** Verify the Doppler capability. shellcheck shell=bash ==============================================================================
  - **Learn from it:** Learn how to verify actual platform behavior rather than only validating static manifests.

- **`scripts/platform-verification/security/verify-external-secrets.sh`**
  - **Contains:** Verify the External Secrets Operator capability. shellcheck shell=bash ==============================================================================
  - **Learn from it:** Learn how to verify actual platform behavior rather than only validating static manifests.

- **`scripts/platform-verification/security/verify-kyverno.sh`**
  - **Contains:** Verify the Kyverno capability. shellcheck shell=bash ==============================================================================
  - **Learn from it:** Learn how to verify actual platform behavior rather than only validating static manifests.

- **`scripts/platform-verification/tests/cert-manager.md`**
  - **Contains:** Documentation titled **cert-manager Manual Validation**. Run the commands from a workstation with `kubectl` configured for the target cluster. The checks are read-only and do not modify cluster resources. Main sections include `Prerequisites`, `Argo CD Application`, `Workloads and Services`, `CRDs and API Readiness`, `TPVF Command`, `Troubleshooting`.
  - **Learn from it:** Learn how to verify actual platform behavior rather than only validating static manifests.

- **`scripts/platform-verification/tests/test-backstage.sh`**
  - **Contains:** Verifies the deployed `backstage` capability through reusable Kubernetes and Argo CD checks.
  - **Learn from it:** Learn how to verify actual platform behavior rather than only validating static manifests.

- **`scripts/platform-verification/tests/test-doppler.sh`**
  - **Contains:** Verifies the deployed `doppler` capability through reusable Kubernetes and Argo CD checks.
  - **Learn from it:** Learn how to verify actual platform behavior rather than only validating static manifests.

- **`scripts/platform-verification/tests/test-external-secrets.sh`**
  - **Contains:** Verifies the deployed `external-secrets` capability through reusable Kubernetes and Argo CD checks.
  - **Learn from it:** Learn how to verify actual platform behavior rather than only validating static manifests.

- **`scripts/platform-verification/tests/test-grafana.sh`**
  - **Contains:** Verifies the deployed `grafana` capability through reusable Kubernetes and Argo CD checks.
  - **Learn from it:** Learn how to verify actual platform behavior rather than only validating static manifests.

- **`scripts/platform-verification/tests/test-kyverno.sh`**
  - **Contains:** Verifies the deployed `kyverno` capability through reusable Kubernetes and Argo CD checks.
  - **Learn from it:** Learn how to verify actual platform behavior rather than only validating static manifests.

- **`scripts/platform-verification/tests/test-loki.sh`**
  - **Contains:** Verifies the deployed `loki` capability through reusable Kubernetes and Argo CD checks.
  - **Learn from it:** Learn how to verify actual platform behavior rather than only validating static manifests.

- **`scripts/platform-verification/tests/test-prometheus.sh`**
  - **Contains:** Verifies the deployed `prometheus` capability through reusable Kubernetes and Argo CD checks.
  - **Learn from it:** Learn how to verify actual platform behavior rather than only validating static manifests.

- **`scripts/platform-verification/tests/test-workloads.sh`**
  - **Contains:** Verifies the deployed `workloads` capability through reusable Kubernetes and Argo CD checks.
  - **Learn from it:** Learn how to verify actual platform behavior rather than only validating static manifests.

- **`scripts/platform-verification/verify.sh`**
  - **Contains:** Main command-line interface for the Platform Verification Framework. Responsibilities: - Bootstrap the framework - Parse command-line arguments - Dispatch verification profiles - Dispatch capability verifiers This file intentionally contains no verification logic. shellcheck shell=bash ========================================================================… It defines functions `show_help`, `show_version`, `run_command`, `main`.
  - **Learn from it:** Learn how to verify actual platform behavior rather than only validating static manifests.

- **`scripts/platform-verification/workloads/verify-demo-service.sh`**
  - **Contains:** Verifies the deployed `demo-service` capability through reusable Kubernetes and Argo CD checks.
  - **Learn from it:** Learn how to verify actual platform behavior rather than only validating static manifests.

### `scripts/release`

- **`scripts/release/package.sh`**
  - **Contains:** Builds a sanitized release ZIP and SHA-256 checksum from tracked source content.
  - **Learn from it:** Learn how public artifacts are generated reproducibly without leaking local history or credentials.

## Important execution paths to study

### Argo CD bootstrap path

`infrastructure/ansible/playbooks/argocd.yml` → `roles/argocd_bootstrap/` → `gitops/bootstrap/root-application/` → `gitops/environments/<environment>/` → `gitops/projects/` and `gitops/applications/`.

### Platform service deployment path

`gitops/applications/platform/<domain>/<service>/application-<environment>.yaml` selects the chart, chart version, destination namespace, and matching `platform-services/<service>/values/<environment>.yaml` file. Argo CD then renders and reconciles the chart.

### Demo workload path

`gitops/applications/workloads/demo-service/application-<environment>.yaml` points to `workloads/demo-service/overlays/<environment>/`, which inherits `workloads/demo-service/base/`. The catalog entity and TechDocs live beside the workload so product metadata evolves with deployment code.

### Static validation path

`make validate` invokes YAML, shell, Kustomize, Markdown, and repository-policy checks. `make security` adds secret and filesystem/misconfiguration scanning. GitHub workflows call the same commands so local and CI behavior remain aligned.

### Runtime verification path

`scripts/platform-verification/verify.sh` bootstraps reusable libraries, selects a profile or capability, executes Argo CD/Kubernetes checks, records state, and produces a report. Component scripts contain capability-specific assertions while profiles choose verification breadth.

## Glossary

- **Application:** An Argo CD custom resource describing one deployable unit and its desired source/destination.
- **AppProject:** An Argo CD security and tenancy boundary governing permitted sources, destinations, and resource types.
- **App-of-apps:** A root Argo CD Application that creates and manages child Applications.
- **Backstage entity:** Catalog metadata describing ownership, lifecycle, system relationships, documentation, and operational links.
- **Base/overlay:** A Kustomize pattern where reusable manifests live in a base and environment-specific differences live in overlays.
- **GitOps:** An operating model in which Git contains desired state and a controller continuously reconciles the running system to it.
- **Helm values:** Environment-specific inputs applied to a reusable Helm chart.
- **Kustomization:** A manifest describing how Kubernetes resources are composed and patched without templating them.
- **Policy-as-code:** Machine-enforced security or governance rules versioned and reviewed like application code.
- **Runtime verification:** Tests against the deployed system, complementing static source validation.
- **Specification-driven development:** A workflow linking approved requirements and acceptance criteria to implementation and evidence.

---

