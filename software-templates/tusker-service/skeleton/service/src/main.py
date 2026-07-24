from fastapi import FastAPI

app = FastAPI(title="${{ values.name }}", version="0.1.0")


@app.get("/")
def root() -> dict[str, str]:
    return {
        "service": "${{ values.name }}",
        "status": "running",
        "description": "${{ values.description }}",
    }


@app.get("/healthz")
def health() -> dict[str, str]:
    return {"status": "ok"}


@app.get("/readyz")
def readiness() -> dict[str, str]:
    return {"status": "ready"}
