# Developer journey

The developer works in the application repository, not the platform repository. Backstage creates the repository and grants access. The developer clones it, runs local tests, creates a feature branch and opens a pull request. CI applies the standard quality and security gates automatically. A merge produces an immutable image and a separate release PR. The developer can observe deployment state through Backstage without cluster-admin access.
