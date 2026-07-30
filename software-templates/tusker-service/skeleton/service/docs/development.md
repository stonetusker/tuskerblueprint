# Development

## Setup

```bash
python3 -m venv .venv
source .venv/bin/activate
python -m pip install -r requirements-dev.txt
```

## Run

```bash
uvicorn src.main:app --reload --port ${{ values.port }}
```

## Verify

```bash
scripts/verify.sh
```

Work on a feature branch and use a pull request. Direct changes to protected `main` are not part of the supported developer path.
