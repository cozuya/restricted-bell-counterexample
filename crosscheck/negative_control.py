#!/usr/bin/env python3
"""Ensure the independent verifier rejects a corrupted supplied certificate."""
import json
import subprocess
import sys
import tempfile
from pathlib import Path

root = Path(__file__).resolve().parent.parent
if not __debug__:
    raise SystemExit('Python assertions must be enabled')
original = json.loads((root / 'original/certificates/witness.json').read_text())
with tempfile.TemporaryDirectory(prefix='restricted-bell-control-') as temporary:
    directory = Path(temporary)
    for field in ['top_coefficients', 'determinant']:
        damaged = json.loads(json.dumps(original))
        if field == 'top_coefficients': damaged[field][1] += 1
        else: damaged[field] = -damaged[field]
        path = directory / 'damaged.json'
        path.write_text(json.dumps(damaged))
        result = subprocess.run([sys.executable, str(root / 'crosscheck/independent_check.py'),
                                 str(path), '--out', str(directory / 'output.json')],
                                capture_output=True, text=True)
        if result.returncode == 0 or 'AssertionError' not in result.stderr:
            raise SystemExit('FAIL: negative control did not reject ' + field)
        print('PASS: independent verifier rejects corrupted ' + field + '.')
