#!/usr/bin/env python3
"""Audit pinned dependencies, project proof sources, and exact axiom inventories."""
import argparse
import hashlib
import json
import re
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
STANDARD = {'propext', 'Classical.choice', 'Quot.sound'}
TARGETS = [
    'Verification.counting_definition_nonreal', 'Verification.conjecture_false',
    'RestrictedBell.restrictedBell_800_5_nonreal',
    'RestrictedBell.realRootedness_conjecture_false',
    'RestrictedBell.countingBell_coeff_eq_stirling',
    'RestrictedBell.countingBell_eq_recurrenceBell',
    'RestrictedBell.ComputedRows.row800_correct',
    'RestrictedBell.countingBell_certificate_bridge',
    'RestrictedBell.countingBell_800_5_monic',
    'RestrictedBell.countingBell_800_5_ne_zero',
    'RestrictedBell.countingBell_800_5_natDegree',
    'RestrictedBell.Certificate.quadratic_exact',
    'RestrictedBell.Certificate.newton_antidiagonal',
]


def require(condition, message):
    if not condition:
        raise SystemExit('FAIL: ' + message)


def output(*args):
    return subprocess.check_output(args, cwd=ROOT, text=True).strip()


def lean_sources():
    return sorted([ROOT / 'RestrictedBell.lean', ROOT / 'Verification.lean',
                   *(ROOT / 'RestrictedBell').rglob('*.lean')])


def strip_comments(text):
    """Remove nested Lean block comments and line comments, preserving newlines."""
    result = []
    i, depth = 0, 0
    while i < len(text):
        if text.startswith('/-', i):
            depth += 1
            result.append('  ')
            i += 2
        elif depth and text.startswith('-/', i):
            depth -= 1
            result.append('  ')
            i += 2
        elif depth:
            result.append('\n' if text[i] == '\n' else ' ')
            i += 1
        elif text.startswith('--', i):
            end = text.find('\n', i)
            if end < 0:
                break
            result.append('\n')
            i = end + 1
        else:
            result.append(text[i])
            i += 1
    require(depth == 0, 'unclosed Lean comment')
    return ''.join(result)


def pins():
    p = json.loads((ROOT / 'TOOLCHAIN.json').read_text())
    require(output('lean', '--short-version') == p['lean_version'], 'Lean version')
    require(output('lean', '--githash') == p['lean_commit'], 'Lean commit')
    require(p['lake_version'] in output('lake', '--version'), 'Lake version')
    require((ROOT / 'lean-toolchain').read_text().strip() ==
            'leanprover/lean4:v' + p['lean_version'], 'lean-toolchain')
    lock = json.loads((ROOT / 'lake-manifest.json').read_text())
    require(lock['packagesDir'] == '.lake/packages', 'dependency directory')
    for package in lock['packages']:
        require(package['type'] == 'git', 'non-Git dependency')
        repo = ROOT / '.lake/packages' / package['name']
        require(output('git', '-C', str(repo), 'rev-parse', 'HEAD') == package['rev'],
                'dependency revision: ' + package['name'])
        require(not output('git', '-C', str(repo), 'status', '--porcelain', '--untracked-files=no'),
                'modified tracked dependency files: ' + package['name'])
        if package['name'] == 'mathlib':
            require(package['rev'] == p['mathlib_commit'], 'Mathlib pin')
    print('PASS: Lean, Lake, and all nine locked dependency revisions.')


def sources():
    forbidden = re.compile(r'\b(sorry|sorryAx|admit|axiom|unsafe|native_decide|'
                           r'ofReduceBool|trustCompiler|implemented_by|extern|csimp|'
                           r'opaque|elab|macro|syntax|initialize|run_tac)\b')
    for path in lean_sources():
        text = strip_comments(path.read_text())
        match = forbidden.search(text)
        require(match is None, f'{path.relative_to(ROOT)}: forbidden token {match}')
        options = re.findall(r'\bset_option\s+(\S+)', text)
        require(set(options) <= {'maxHeartbeats', 'maxRecDepth'},
                f'{path.relative_to(ROOT)}: unexpected options {options}')
        attributes = re.findall(r'@\[([^\]]*)\]', text)
        expected = ['simp'] if path.name == 'PartitionRecurrence.lean' else []
        require('attribute ' not in text and attributes == expected,
                f'{path.relative_to(ROOT)}: unexpected attributes')
    # The main theorem must not import the supplementary profile arithmetic,
    # even indirectly. All local imports use one module per line.
    pending, closure = ['RestrictedBell.Final'], set()
    while pending:
        module = pending.pop()
        if module in closure:
            continue
        closure.add(module)
        path = ROOT / (module.replace('.', '/') + '.lean')
        imports = re.findall(r'^import\s+(RestrictedBell(?:\.\w+)*)\s*$',
                             strip_comments(path.read_text()), re.M)
        pending.extend(imports)
    require('RestrictedBell.Coefficients' not in closure,
            'final theorem imports supplementary profile arithmetic')
    print(f'PASS: {len(lean_sources())} active Lean files; no placeholders, custom axioms, '
          'native_decide, or unsafe declarations.')
    print('PASS: Final.lean has no dependency on supplementary Coefficients.lean.')


def axioms(path):
    text = Path(path).read_text()
    require(not re.search(r'\b(warning|error|sorryAx)\b', text, re.I),
            'diagnostic or placeholder in statement/axiom log')
    reports = re.findall(r"'([^']+)' depends on axioms: \[([^\]]*)\]", text)
    require(len(reports) == len(TARGETS), 'wrong axiom report count')
    require({name for name, _ in reports} == set(TARGETS), 'wrong audited declarations')
    for name, body in reports:
        require(set(x.strip() for x in body.split(',')) == STANDARD,
                'unexpected axioms for ' + name)
    for name in TARGETS[:6] + [
            'RestrictedBell.countingBell_certificate_bridge',
            'RestrictedBell.countingBell_800_5_monic',
            'RestrictedBell.countingBell_800_5_ne_zero',
            'RestrictedBell.countingBell_800_5_natDegree']:
        require(re.search(r'^' + re.escape(name) + r'\b', text, re.M),
                'missing printed theorem type: ' + name)
    print(f'PASS: all {len(TARGETS)} declarations use exactly propext, Classical.choice, Quot.sound.')


def source_paths():
    paths = lean_sources()
    for name in ['scripts', 'crosscheck', 'original', 'provenance', '.github/workflows']:
        paths += [p for p in (ROOT / name).rglob('*')
                  if p.is_file() and '__pycache__' not in p.parts and p.suffix != '.pyc']
    paths += [ROOT / n for n in ['verify.sh', 'lakefile.toml', 'lake-manifest.json',
                                'lean-toolchain', 'TOOLCHAIN.json']]
    return sorted(set(p.relative_to(ROOT).as_posix() for p in paths))


def hashes():
    return {name: hashlib.sha256((ROOT / name).read_bytes()).hexdigest()
            for name in source_paths()}


def check_hashes():
    expected = {}
    for line in (ROOT / 'SOURCE_SHA256SUMS').read_text().splitlines():
        digest, name = line.split('  ', 1)
        require(name not in expected, 'duplicate source hash: ' + name)
        expected[name] = digest
    require(expected == hashes(), 'source manifest differs from verification inputs')
    print(f'PASS: complete SHA-256 inventory of {len(expected)} verification inputs.')


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('mode', choices=['pins', 'sources', 'axioms', 'hashes', 'write-hashes'])
    parser.add_argument('log', nargs='?')
    args = parser.parse_args()
    if args.mode == 'pins': pins()
    elif args.mode == 'sources': sources()
    elif args.mode == 'axioms':
        require(args.log is not None, 'supply an axiom log')
        axioms(args.log)
    elif args.mode == 'hashes': check_hashes()
    else:
        (ROOT / 'SOURCE_SHA256SUMS').write_text(''.join(
            f'{digest}  {name}\n' for name, digest in hashes().items()))
        print('Wrote SOURCE_SHA256SUMS.')


if __name__ == '__main__':
    main()
