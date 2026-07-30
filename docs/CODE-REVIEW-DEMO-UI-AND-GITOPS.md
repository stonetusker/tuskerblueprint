# Code review: demo UI, Argo CD and service access

## Scope

The review covered the maintained Customer Notification demo, the Backstage
Tusker Service skeleton, generated Argo CD Applications, Kubernetes Services and
NetworkPolicies, OpenAPI, TechDocs, tests, workflows and operator access scripts.

## Deployment findings

- The maintained demo is deployed by `demo-service-development` into namespace
  `demo-service-development`.
- A generated service named `customer-orders-api` is deployed by
  `customer-orders-api-development` into `customer-orders-api-development`.
- The `generated-workloads` controller reads Application manifests from the
  TuskerBlueprint repository. Each generated Application reads only its declared
  service repository and `deploy/overlays/development` path.
- No Application definition clones unrelated service repositories.

## Access findings

- Workload Services remain `ClusterIP`; no accidental public exposure was added.
- Browser access is repeatable through `scripts/demo/open-demo-ui.sh`.
- Approved service namespaces are labeled by Argo CD with
  `platform.stonetusker.com/workload=true`.
- NetworkPolicies allow inbound traffic from platform components and approved
  workloads.
- Default-deny egress remains active. Explicit egress allows cluster DNS and
  communication only to approved workload namespaces.

## Application review

- The UI is bundled into the existing FastAPI image, so there is no second image,
  Node.js build pipeline or independent deployment to fail during the demo.
- Dynamic UI content is written with `textContent`; `innerHTML` is not used.
- UI assets are local and do not depend on public CDNs.
- Security headers include CSP, frame denial, no-sniff, no-referrer and a limited
  permissions policy.
- Notification recipients and messages are still validated by Pydantic.
- Notification records remain deliberately in memory and are documented as a
  demo-only persistence boundary.
- List pagination is bounded from 1 to 50 records.

## Automated checks completed

- Python syntax compilation
- JavaScript syntax validation with Node.js
- YAML parsing
- Duplicate-key-protected repository validation
- Public and private template rendering
- Generated-template application tests
- Maintained demo tests: 8 passed
- Maintained demo coverage: 94.15 percent
- OpenAPI and TechDocs checks
- Shell syntax validation
- Repository hygiene validation
- 464 source and structure checks before final packaging

The packaging environment did not provide the pinned Ruff and Mypy packages,
so their exact CLI checks could not be rerun locally. The corresponding commands
remain mandatory in `.github/workflows/demo-service-ci.yml`, and the changed
Python is compiled and exercised by the test suite and rendered-template tests.

## Remaining operational boundary

The archive changes source and GitOps desired state. The current cluster will not
show the UI until the demo-service CI publishes a new image, the immutable image
release pull request is merged, and Argo CD reconciles that release.
