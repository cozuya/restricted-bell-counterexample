#!/usr/bin/env bash
set -euo pipefail
cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.."
mkdir -p .build
python3 -c 'import sys; sys.exit("Python assertions must be enabled") if not __debug__ else None'
python3 original/code/check.py
python3 crosscheck/independent_check.py original/certificates/witness.json \
  --out .build/independent-certificate.json
cmp crosscheck/independent-certificate.json .build/independent-certificate.json
python3 crosscheck/negative_control.py
printf 'CROSSCHECK=PASS\n'
