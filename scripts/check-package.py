#!/usr/bin/env python3
"""Check the public inventory, local documentation links, and recorded verification inputs."""
import json
import os
import re
from pathlib import Path
from urllib.parse import unquote
from audit import ROOT, axioms, check_hashes, hashes, require, source_paths

DOCS = {'README.md', 'PROOF.md', 'REPRODUCE.md', 'VERIFICATION_REPORT.md',
        'PROVENANCE.md', 'PRIOR_ART.md', 'CITATION.cff', 'LICENSE', 'RELEASE.md',
        '.gitignore', 'SOURCE_SHA256SUMS', '.github/repository.json'}
EVIDENCE = {'evidence/' + name for name in ['verification.log', 'verification.json',
            'kernel-check.log', 'build.log', 'crosscheck.log', 'independent-certificate.json']}
GENERATED = {'.git', '.lake', '.tools', '.build', '__pycache__'}


def main():
    expected = set(source_paths()) | DOCS | EVIDENCE
    actual = set()
    for directory, dirs, files in os.walk(ROOT):
        dirs[:] = [d for d in dirs if d not in GENERATED]
        for name in files:
            path = Path(directory) / name
            require(not path.is_symlink(), 'symlink in public package: ' + str(path))
            actual.add(path.relative_to(ROOT).as_posix())
    require(actual == expected,
            f'public inventory: missing={sorted(expected-actual)}, extra={sorted(actual-expected)}')
    check_hashes()
    evidence = json.loads((ROOT / 'evidence/verification.json').read_text())
    require(evidence['exit_code'] == 0 and evidence['clean_project_build'], 'failed/incremental evidence')
    require(evidence['source_hashes'] == hashes(), 'recorded evidence is for different sources')
    require(all(step['exit_code'] == 0 for step in evidence['steps']), 'failed recorded step')
    axioms(ROOT / 'evidence/kernel-check.log')
    require(json.loads((ROOT / 'evidence/independent-certificate.json').read_text()) ==
            json.loads((ROOT / 'crosscheck/independent-certificate.json').read_text()),
            'independent certificate rerun differs')
    for name in sorted(actual):
        if not name.endswith('.md') or name.startswith(('original/research/', 'provenance/independent/')):
            continue  # Historical documents retain their original relative paths and math markup.
        path = ROOT / name
        for target in re.findall(r'\]\(([^)\s]+)\)', path.read_text()):
            if re.match(r'^[a-zA-Z]+:', target) or target.startswith('#'):
                continue
            target = unquote(target.split('#', 1)[0])
            require((path.parent / target).exists(), f'broken link in {name}: {target}')
    metadata = json.loads((ROOT / '.github/repository.json').read_text())
    require(metadata['release_tag'] == 'v1.0.0', 'release tag')
    require(len(metadata['topics']) <= 20 and all(
        re.fullmatch(r'[a-z0-9][a-z0-9-]{0,49}', t) for t in metadata['topics']), 'topic syntax')
    print(f'PASS: {len(actual)} public files, documentation links, release metadata, and source-bound evidence.')


if __name__ == '__main__':
    main()
