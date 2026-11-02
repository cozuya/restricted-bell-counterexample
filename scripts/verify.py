#!/usr/bin/env python3
"""Record a clean Lean rebuild and exact certificate checks, identified by source hashes."""
import datetime
import json
import os
import platform
import resource
import shutil
import subprocess
import sys
import time
from pathlib import Path
from audit import ROOT, TARGETS, hashes, require


def now():
    return datetime.datetime.now(datetime.timezone.utc).isoformat()


def main():
    require(__debug__, 'Python assertions must be enabled')
    for program in ['lean', 'lake', 'git', 'bash']:
        require(shutil.which(program), 'missing prerequisite: ' + program)
    os.chdir(ROOT)
    build = ROOT / '.build'
    build.mkdir(exist_ok=True)
    initial_hashes = hashes()
    record = {'started_utc': now(), 'platform': platform.system() + ' ' + platform.machine(),
              'python': platform.python_version(),
              'lean_num_threads': os.environ.get('LEAN_NUM_THREADS'),
              'source_hashes': initial_hashes,
              'trust_model': 'Lean kernel; propext, Classical.choice, Quot.sound',
              'audited_declarations': TARGETS, 'steps': [], 'exit_code': 1}
    started = time.monotonic()
    with (build / 'verification.log').open('w') as log:
        def emit(line):
            print(line, end='', flush=True)
            log.write(line)
            log.flush()

        def run(command, capture=None):
            emit('\n$ ' + ' '.join(command) + '\n')
            before = time.monotonic()
            saved = (build / capture).open('w') if capture else None
            try:
                with subprocess.Popen(command, stdout=subprocess.PIPE,
                                      stderr=subprocess.STDOUT, text=True) as process:
                    for line in process.stdout:
                        emit(line)
                        if saved: saved.write(line)
                    code = process.wait()
            finally:
                if saved: saved.close()
            elapsed = round(time.monotonic() - before, 3)
            record['steps'].append({'command': command, 'exit_code': code,
                                    'wall_seconds': elapsed})
            emit(f'EXIT_CODE={code} WALL_SECONDS={elapsed}\n')
            if code: raise RuntimeError('command failed: ' + ' '.join(command))

        try:
            run(['lean', '--version'])
            run(['lean', '--githash'])
            run(['lake', '--version'])
            for mode in ['pins', 'sources', 'hashes']:
                run(['python3', 'scripts/audit.py', mode])
            run(['python3', 'scripts/check_sources.py'])
            run(['python3', 'scripts/generate_rows.py', '--check'])
            project_build = ROOT / '.lake/build'
            require(not project_build.is_symlink(), 'project build directory is a symlink')
            if project_build.exists(): shutil.rmtree(project_build)
            record['clean_project_build'] = True
            emit('\nRemoved project build outputs; retained dependency caches.\n')
            run(['lake', '--wfail', 'build'], 'build.log')
            run(['lake', 'env', 'lean', '--trust=0', 'Verification.lean'], 'kernel-check.log')
            run(['python3', 'scripts/audit.py', 'axioms', '.build/kernel-check.log'])
            run(['bash', 'crosscheck/run.sh'], 'crosscheck.log')
            require(hashes() == initial_hashes, 'verification inputs changed during the run')
            record['exit_code'] = 0
            emit('\nFULL_REBUILD=PASS\nEXACT_STATEMENTS=PASS\nAXIOM_AUDIT=PASS\nCROSSCHECK=PASS\n')
        except (Exception, SystemExit) as error:
            emit('\nFAIL: ' + str(error) + '\n')
        finally:
            record['finished_utc'] = now()
            record['wall_seconds'] = round(time.monotonic() - started, 3)
            record['max_child_rss_kib'] = resource.getrusage(resource.RUSAGE_CHILDREN).ru_maxrss
            (build / 'verification.json').write_text(json.dumps(record, indent=2) + '\n')
            emit(f'VERIFY_EXIT_CODE={record["exit_code"]}\n')
    return record['exit_code']


if __name__ == '__main__':
    sys.exit(main())
