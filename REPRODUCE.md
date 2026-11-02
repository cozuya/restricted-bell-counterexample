# Reproducing the verification

The public package contains every project source, integer certificate, and
verification script. Mathlib and its transitive dependencies are fetched at
locked revisions. No private project files are needed.

## Requirements

- Linux x86_64 for the supplied installer and recorded run.
- Bash, Git, Python 3.9+, curl, tar, zstd, and coreutils. Python uses only its
  standard library. Keep assertions enabled; do not use `-O` or `PYTHONOPTIMIZE`.
- About 12 GB free disk for Lean, Mathlib caches, and build outputs. The Lean
  download archive takes additional space if retained.
- At least 12 GB available RAM is recommended. A large coefficient batch used
  about 8 GB resident memory in the supplied development run; allow headroom
  for the operating system and other processes. Swap can help smaller machines.
  The fresh run's measured figure is in [VERIFICATION_REPORT.md](VERIFICATION_REPORT.md).

Other platforms can install the version in [lean-toolchain](lean-toolchain)
and use the same Bash commands, but have not been tested for this package.

## Complete run

After obtaining a checkout:

```sh
bash scripts/install-lean.sh
export PATH="$PWD/.tools/lean-4.28.0-linux/bin:$PATH"
bash scripts/fetch-deps.sh
./verify.sh
python3 scripts/check-package.py
```

The installer verifies the Linux release archive's SHA-256 and checks the
compiler version and commit. If that compiler is already installed, put its
`bin` directory on `PATH`, or supply `LEAN_BIN_DIR` to `fetch-deps.sh` and
`verify.sh`. [TOOLCHAIN.json](TOOLCHAIN.json) records the exact pins.

`fetch-deps.sh` runs `lake exe cache get`, requires the dependency lockfile to
remain unchanged, and checks every dependency checkout against the lockfile.
There is no `lake update` step. Only dependencies use the prebuilt cache.

`verify.sh` defaults `LEAN_NUM_THREADS` to 2. Its nine generated coefficient
batches depend on one another and therefore compile sequentially. Other
independent modules may compile concurrently.

## What is checked

1. Exact Lean/Lake identities and all nine dependency revisions, with no
   modifications to tracked dependency files.
2. Active Lean sources, rejecting placeholders, custom axioms, `native_decide`,
   unsafe declarations, and unexpected options or attributes. This source
   scan supplements the actual Lean build and axiom check. It also checks
   that `Final.lean` does not import the supplementary profile arithmetic.
3. The complete [source hash inventory](SOURCE_SHA256SUMS), preservation of the
   original public inputs, exact transcription of certificate integers, and
   the complete recorded diff from the original Lean sources.
4. Reproducibility of all 801 generated coefficient rows.
5. A clean rebuild after deleting only `.lake/build`. Dependency caches are kept.
6. `lake env lean --trust=0 Verification.lean`, checking the explicit counting
   definition and conjecture statement and printing thirteen axiom inventories.
   These include monicity, nonzero, and degree 800. Two small counting checks
   also establish $S_{\le2}(4,2)=3$ and $S_{\le3}(4,2)=7$ through the proved bridge.
7. Exact agreement of each inventory with
   `[propext, Classical.choice, Quot.sound]`; unexpected diagnostics fail the run.
8. Both Python verifiers, exact agreement of the independent certificate, and
   rejection of two deliberately corrupted certificates.
9. Stability of all verification inputs throughout the run.

Successful output ends with `VERIFY_EXIT_CODE=0`.

## Outputs and individual checks

Fresh outputs are in the ignored `.build/` directory:
`verification.json`, `verification.log`, `build.log`, `kernel-check.log`,
`crosscheck.log`, and `independent-certificate.json`.
The [evidence/](evidence) directory preserves the completed local package run.
`check-package.py` verifies its source identities as well as public inventory
and documentation links. Source identities work before a first Git commit.

Useful separate commands:

```sh
python3 scripts/audit.py sources
python3 scripts/audit.py hashes
python3 scripts/check_sources.py
python3 scripts/generate_rows.py --check
bash crosscheck/run.sh
```

To regenerate row proposals, run `python3 scripts/generate_rows.py`, then
rebuild. If active Lean sources change, record and review their exact differences
from the preserved archive with `python3 scripts/check_sources.py --write-patch`.
Changing verified sources also requires updating `SOURCE_SHA256SUMS` with
`python3 scripts/audit.py write-hashes`, running `./verify.sh`, and refreshing
the six files in `evidence/` before the package checker will pass. Updating
hashes or recording a diff alone does not establish correctness.

## Continuous integration

[verify.yml](.github/workflows/verify.yml) installs the pinned compiler, fetches
dependencies, validates the packaged evidence, and performs the same full run.
It provisions swap for the large coefficient batches and uploads fresh logs
even on failure. It is configured for main pushes, version tags, pull requests,
manual dispatch, and a change to public visibility. Hosted execution is a
separate event from the recorded local run; see the verification report.
