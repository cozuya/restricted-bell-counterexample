# Verification report

**Result: PASS.** A clean local rebuild on 2026-11-02 checked the revised
restricted Bell counterexample, its explicit counting-definition restatement,
and the new monicity, nonzero, and degree results. All 13 audited declarations
depend on exactly:

```text
[propext, Classical.choice, Quot.sound]
```

There are no `native_decide` dependencies or custom axioms in those declarations.
The source audit also rejects placeholder proofs, unsafe declarations, and
unexpected compiler options or attributes.

## What was run

The complete commands and their exit codes are preserved in
[evidence/verification.log](evidence/verification.log). The machine-readable
[run record](evidence/verification.json) identifies all 56 verification inputs
by SHA-256. These match [SOURCE_SHA256SUMS](SOURCE_SHA256SUMS).

| Check | Result |
| --- | --- |
| Lean 4.28.0, Lake, and all nine locked dependency revisions | PASS |
| Scan of all 23 active Lean files | PASS |
| Final theorem's import graph excludes supplementary `Coefficients.lean` | PASS |
| Original public inputs and independent audit hashes | PASS |
| All active Lean changes match the complete diff from the preserved archive | PASS |
| Exact certificate transcription into Lean | PASS |
| Regeneration check of 801 coefficient rows in nine batches | PASS |
| Clean rebuild of all 22 project modules | PASS; 8,048 Lake jobs including cached dependencies |
| Explicit counting-definition and conjecture statements under `--trust=0` | PASS |
| Explicit monicity, nonzero, and degree 800 lemmas | PASS |
| Small counting examples $S_{\le2}(4,2)=3$ and $S_{\le3}(4,2)=7$ | PASS |
| Exact standard-axiom inventory for all 13 declarations | PASS |
| Original complete-coefficient and determinant verifier | PASS |
| Independent profile, moment, matrix, and negative-vector verifier | PASS |
| Independent certificate rerun matches preserved certificate byte-for-byte | PASS |
| Corrupted coefficient and reversed determinant sign are rejected | PASS |
| Verification inputs unchanged throughout the run | PASS |

The exact theorem output is in [kernel-check.log](evidence/kernel-check.log).
The main declarations are:

```lean
RestrictedBell.restrictedBell_800_5_nonreal :
  ∃ z : ℂ, (RestrictedBell.countingBell 800 5).IsRoot z ∧ z.im ≠ 0

RestrictedBell.realRootedness_conjecture_false :
  ¬ RestrictedBell.RealRootednessConjecture

RestrictedBell.countingBell_800_5_monic :
  (RestrictedBell.countingBell 800 5).Monic

RestrictedBell.countingBell_800_5_ne_zero :
  RestrictedBell.countingBell 800 5 ≠ 0

RestrictedBell.countingBell_800_5_natDegree :
  (RestrictedBell.countingBell 800 5).natDegree = 800
```

[Verification.lean](Verification.lean) additionally writes out the bounded
finite-partition sum and the conjecture's quantified positive-cap restrictions.
The final proof connects counting coefficients directly to the certificate
through `countingBell_certificate_bridge`. Supplementary profile calculations
remain compiled and checked, but are not imported by the final theorem or the
verification entry point.

The axiom audit includes both explicit restatements, both final results, the
three monicity/nonzero/degree lemmas, the general counting recurrence and
polynomial equality, row 800, the direct coefficient bridge, the exact quadratic
form, and the Newton equations. The two small counting examples use the proved
counting bridge and the recurrence equations.

## Measured local run

- Start: `2026-11-02T22:21:24.747823+00:00`; finish: `2026-11-02T22:27:08.578889+00:00`.
- Platform: Linux x86_64; Python 3.14.4; `LEAN_NUM_THREADS=2`.
- Clean Lean build: 329.689 seconds. Statement/axiom entry point: 10.560 seconds.
- Complete verification: 342.068 seconds.
- Maximum child-process resident memory reported by Linux: 7,818,040 KiB
  (about 7.46 GiB). This is a process high-water mark,
  not the aggregate peak of all concurrently running processes.

## Computational evidence

The [Python transcript](evidence/crosscheck.log) confirms:

- All 801 coefficients of $B_{800,\le5}$, its factor $x^{160}$, and a monic
  quotient of degree 640.
- Agreement of the 39 leading coefficients and 39 moments between implementations.
- A 20 by 20 Hankel matrix with its first 19 leading principal determinants
  positive and its twentieth negative, with
  $-8\cdot10^{1087}<\det H<-7\cdot10^{1087}$.
- A primitive integer vector of length 20 with negative quadratic form.
  The vector entries have at most 447 digits; the form has 897 digits in
  absolute value.

The Lean proof checks the negative-vector certificate directly. It does not
rely on either Python determinant implementation or on numerical root finding.
The original source archive is preserved unchanged, and
[public-source.patch](provenance/lean/public-source.patch) records every change
to its `RestrictedBell` sources. Applying that patch was separately checked to
reconstruct all active `RestrictedBell` sources byte-for-byte.

## Reproduction and limits

Run `./verify.sh` with the pinned toolchain, then
`python3 scripts/check-package.py`; see [REPRODUCE.md](REPRODUCE.md).
The package checker confirms the recorded run's input identity, public inventory,
local documentation links, release metadata, and independent certificate.

The local run reused compatible caches for Mathlib and its pinned dependencies.
It removed this project's build outputs before rebuilding all project modules.
It did not rebuild Mathlib from source or test a new compiler download.
Memory measurements depend on the environment and method; the figure above is
the measured value for this run, not a universal minimum memory requirement.

This report records local verification. Subsequent hosted runs of the
[GitHub Actions workflow](.github/workflows/verify.yml) are reported separately
on the [Actions page](https://github.com/cozuya/restricted-bell-counterexample/actions).
The final proofs still rely on Lean's kernel and standard logical axioms and
the ordinary correctness of the software/hardware running the checker.
Formal verification does not establish novelty or historical priority.
