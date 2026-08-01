# Implementation workflow

1. Modify the platform template or platform service.
2. Run `make validate` in the platform repository.
3. Render a sample template and test the generated repository.
4. For application changes, work in the application repository and run `make validate lint test`.
5. Merge application code only after CI passes.
6. Merge the generated immutable release PR.
7. Merge platform onboarding or registration changes.
8. Verify Argo CD and Backstage.
