#!/usr/bin/env bash
# Clean project rebuild, exact counting statement, standard-axiom audit, and cross-checks.
set -euo pipefail
cd -- "$(dirname -- "${BASH_SOURCE[0]}")"
if [[ -n ${LEAN_BIN_DIR:-} ]]; then export PATH="$LEAN_BIN_DIR:$PATH"; fi
export LEAN_NUM_THREADS=${LEAN_NUM_THREADS:-2}
exec python3 scripts/verify.py
