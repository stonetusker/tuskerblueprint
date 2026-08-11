# TuskerBlueprint change set

Copy the included files over the repository root while preserving their relative
paths. Then delete every exact path listed in DELETED_FILES.txt with git rm.

After applying:

    make validate
    scripts/demo/preflight.sh

The first command is offline repository validation. The second requires the live
cluster and is the final recorded-demo gate.
