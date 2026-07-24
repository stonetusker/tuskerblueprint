# ${{ values.name }}

${{ values.description }}

## Ownership

- Owner: `${{ values.owner }}`
- System: `${{ values.system }}`
- Lifecycle: experimental

## Local development

```bash
python -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
uvicorn src.main:app --reload --port ${{ values.port }}
```
