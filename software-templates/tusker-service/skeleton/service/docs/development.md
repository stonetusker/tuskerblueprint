# Development

Create a Python 3.12 virtual environment, install `requirements-dev.txt`, and run `make validate lint test`. Start the service with `make run` and open `http://localhost:8000/`.

Application code is under `app/`; browser assets are under `app/static/`. Keep API changes synchronized with `openapi.yaml` and update TechDocs in the same pull request.
