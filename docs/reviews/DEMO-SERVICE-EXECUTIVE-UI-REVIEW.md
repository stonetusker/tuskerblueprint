# Demo Service Executive UI Review

## Review scope

This review covers the maintained demo service browser experience, FastAPI route,
static assets, test coverage, security headers, container packaging and release
behavior.

## Outcome

The root route now serves a colorful Customer Experience Hub designed for CTO,
VP Engineering and other non-specialist audiences. The existing API, health,
readiness, metrics, structured logging, correlation IDs and controlled failure
modes remain unchanged.

## Design decisions

- No external CDN, web font, JavaScript framework or frontend build chain.
- HTML, CSS and JavaScript are bundled in the existing FastAPI container.
- The interface uses only live service metadata and current-pod notification data.
- Any business-facing claims are framed as platform capabilities or demo-session
  activity rather than production customer statistics.
- The interface remains responsive and supports keyboard navigation,
  reduced-motion preferences and accessible labels.

## Security review

- Existing Content Security Policy remains compatible with the UI.
- Dynamic notification content is rendered with `textContent`; no `innerHTML` is
  used.
- User input is sent as JSON to the existing validated Pydantic model.
- No third-party scripts, trackers or external asset calls were introduced.
- The root document uses `Cache-Control: no-store, max-age=0` so release changes
  are visible during demonstrations.
- Existing security headers remain in place: `X-Content-Type-Options`,
  `X-Frame-Options`, `Referrer-Policy` and `Permissions-Policy`.

## Reliability review

- The UI degrades gracefully if the status or activity API is unavailable.
- Empty session state is presented intentionally rather than appearing broken.
- The application remains a single-container workload with no new runtime
  dependency.
- The old Kubernetes image tag does not contain this UI. A new CI image and
  immutable release pull request must be produced and deployed before the live
  cluster changes.

## Validation performed

- Python compilation
- JavaScript syntax check
- HTML parser check
- Eight application tests
- Repository IDP validation
- Demo structural validation
- Public and private software-template rendering tests
- Repository hygiene checks

## Deployment acceptance

After the new release pull request is merged, the following must be true:

1. `demo-service-development` is `Synced` and `Healthy` in Argo CD.
2. The running image tag equals the merged release SHA.
3. `GET /` returns `text/html`, not the legacy JSON response.
4. `GET /api/v1/status`, `/healthz`, `/readyz` and `/metrics` still succeed.
5. A browser notification request returns HTTP 202 and appears in the activity
   panel with a correlation ID.
