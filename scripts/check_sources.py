#!/usr/bin/env python3
"""Check certificate transcription and preservation of the supplied public inputs."""
import argparse
import difflib
import hashlib
import json
import re
import tarfile
from pathlib import Path
from audit import require

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('--write-patch', action='store_true',
                    help='record current Lean differences from the preserved source archive')
args = parser.parse_args()

root = Path(__file__).resolve().parent.parent
cert = json.loads((root / 'crosscheck/independent-certificate.json').read_text())
source = (root / 'RestrictedBell/Certificate.lean').read_text()
for name, field in [('coefficients', 'top_coefficients'), ('moments', 'moments'),
                    ('vector', 'negative_integer_vector')]:
    match = re.search(r'def ' + name + r' : List ℤ := \[(.*?)\]', source, re.S)
    require(match is not None, 'missing Lean certificate field ' + name)
    values = [int(s.strip().strip('()')) for s in match.group(1).split(',')]
    require(values == cert[field], 'certificate field ' + field)
require(f'quadratic = ({cert["negative_quadratic_form"]})' in source, 'quadratic value')
require(len(cert['negative_integer_vector']) == 20, 'vector length')

supplied = json.loads((root / 'provenance/independent/SHA256.json').read_text())
for name, digest in supplied.items():
    if name.startswith('input/'):
        path = root / 'original' / name.removeprefix('input/')
    elif name.startswith('verification/'):
        short = name.removeprefix('verification/')
        path = root / ('crosscheck' if short.endswith(('.py', '.json'))
                       else 'provenance/independent') / short
    else:
        path = root / 'provenance/independent' / name
    require(hashlib.sha256(path.read_bytes()).hexdigest() == digest,
            'changed original audit input: ' + name)

manifest = json.loads((root / 'provenance/lean/SHA256.json').read_text())
patch = []
with tarfile.open(root / 'provenance/lean/as-received.tar.gz') as archive:
    require(set(archive.getnames()) == set(manifest), 'as-received archive inventory')
    for member in sorted(archive.getmembers(), key=lambda item: item.name):
        require(member.isfile(), 'non-file in source archive')
        data = archive.extractfile(member).read()
        require(hashlib.sha256(data).hexdigest() == manifest[member.name],
                'archive hash: ' + member.name)
        if member.name.startswith('RestrictedBell') and member.name.endswith('.lean'):
            current = (root / member.name).read_text()
            patch.extend(difflib.unified_diff(
                data.decode().splitlines(keepends=True), current.splitlines(keepends=True),
                fromfile='as-received/' + member.name, tofile='public/' + member.name))
patch_path = root / 'provenance/lean/public-source.patch'
if args.write_patch:
    patch_path.write_text(''.join(patch))
    print('Wrote provenance/lean/public-source.patch; review the diff before verification.')
require(patch_path.read_text() == ''.join(patch),
        'active Lean changes differ from the documented source patch')
print('PASS: original proof and independent audit files match their supplied hashes; '
      'all active Lean changes match the documented source patch; certificate literals agree.')
