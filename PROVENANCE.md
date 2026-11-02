# Provenance

**Chris Ozols, with AI-assisted discovery, verification, and formalization.**
Chris directed the project and preparation of this repository.

The original computational refutation was produced through an OpenAI-assisted
research run. The supplied materials then record an independent exact-arithmetic
audit and a later completed Lean formalization. This public bundle does not
establish the precise model identities responsible for those later stages, so
none are asserted here. OpenAI Codex prepared this public package, adapted its
verification infrastructure, and performed the fresh local rebuild recorded
in [evidence/verification.json](evidence/verification.json).

## Stages of the work

| Stage | Preserved record | What it establishes |
| --- | --- | --- |
| Original computational refutation, recovered November 2, 2026 | [original/](original/README.md) | Exact determinant certificate, original verifier, argument, and result snapshot |
| Independent audit, dated November 2, 2026 | [audit report](provenance/independent/AUDIT.md), [independent checker](crosscheck/independent_check.py) | Separate coefficient and matrix calculations; a new negative-vector certificate |
| Subsequent Lean formalization, supplied November 2, 2026 | [source archive](provenance/lean/as-received.tar.gz), [member hashes](provenance/lean/SHA256.json) | The completed source project, including the combinatorial counting bridge and final theorems |
| Public package preparation, November 2, 2026 | [verification report](VERIFICATION_REPORT.md), [fresh evidence](evidence/verification.json) | Clean rebuild of the packaged proof, explicit statement checks, exact axiom inventories, and Python reruns |

The recovery README and independent audit were written before the Lean proof.
Their statements that formalization was absent describe those earlier stages.
The active project's [Final.lean](RestrictedBell/Final.lean) contains the
unconditional theorems. Historical orchestration status in the recovery files
is also distinct from the subsequent mathematical verification.

Dates in supplied records, filesystem metadata, and editable Git metadata are
not authenticated discovery timestamps. Hashes identify exact bytes; they do
not establish historical priority.

## Original computational record

The six original proof files are retained byte-for-byte under [original/](original/README.md).
The original recovery metadata calls the result a `candidate_refutation`;
that label is preserved as historical data. The public mathematical statement
is supported by the current proof and verification evidence.

Private prompts, provider transcripts, execution captures, recovery manifests,
and unrelated exploratory files are outside this public package. No private
archive is needed to reproduce any theorem or check here.

## Independent audit mapping

The audit's own report and hash manifest are retained unchanged. Their original
bundle paths map as follows:

| Original audit path | Public package location |
| --- | --- |
| `input/` | [original/](original/README.md) |
| `verification/independent_check.py` | [crosscheck/independent_check.py](crosscheck/independent_check.py) |
| `verification/independent-certificate.json` | [crosscheck/independent-certificate.json](crosscheck/independent-certificate.json) |
| `verification/independent-verifier.log` | [provenance/independent/independent-verifier.log](provenance/independent/independent-verifier.log) |
| `verification/supplied-verifier.log` | [provenance/independent/supplied-verifier.log](provenance/independent/supplied-verifier.log) |
| `AUDIT.md`, `SHA256.json` | [provenance/independent/](provenance/independent) |

[scripts/check_sources.py](scripts/check_sources.py) verifies every original
audit hash using this mapping. Fresh reruns are stored separately in
[evidence/](evidence), so historical records are not overwritten.

## Lean source preservation and packaging changes

[as-received.tar.gz](provenance/lean/as-received.tar.gz) was constructed from the
supplied public Lean sources, original `Main.lean`, build configuration, and
source scripts. Archive timestamps and owner fields are normalized; it is a
source preservation archive, not a copy of the entire recovered working folder.
Its [manifest](provenance/lean/SHA256.json) records the exact member bytes.

The original source archive is unchanged. All differences between its
`RestrictedBell` sources and the active project are recorded in
[public-source.patch](provenance/lean/public-source.patch).
`check_sources.py` regenerates the complete diff from the preserved archive and
requires it to match that file, including comments and whitespace.

Packaging changes are:

- `Verification.lean` replaces the former `Main.lean` audit entry point and adds
  explicit counting-definition and conjecture statements. It audits the
  monicity, nonzero, and degree lemmas and checks two small counting examples.
- The final proof uses `countingBell_certificate_bridge` to connect the counting
  coefficients directly to `Certificate.c`. The original profile calculations
  and profile bridge are retained in the supplementary `Coefficients.lean`,
  which is no longer imported by the final theorem.
- `Final.lean` exports monicity, nonzeroness, and degree 800 explicitly. Comments
  describing now-closed proof obligations have been corrected.
- `lakefile.toml` prepares version 1.0.0 and builds the `RestrictedBell` library;
  the verification entry point runs separately under `--trust=0`.
- The generator's certificate path is adapted to the public layout. Its generated
  row sources remain byte-identical.
- The reproduction scripts, source/axiom audits, negative controls, workflow,
  public documentation, citation, license, and proposed release metadata are added.

The layout follows Chris Ozols's
[gyires-permanent-4x4](https://github.com/cozuya/gyires-permanent-4x4) repository.
The Lean installer and dependency-fetch script are reused from that Apache-2.0
package. The verification logic here is adapted to the standard-axiom proof.

These refinements followed a review supplied by Chris, which reported a separate
clean build and suggested a simpler coefficient bridge and explicit nonzero
results. That review's build logs and source hashes are not part of this bundle;
the verification report here records the fresh local checks of the revised code.

## Evidence and attribution limits

[SOURCE_SHA256SUMS](SOURCE_SHA256SUMS) inventories all verification inputs and
preserved source records. The machine-readable run report identifies those
same inputs by hash, independent of whether a Git commit already exists.
Only Mathlib and dependency caches were reused for the local run; this
project's build outputs were removed before rebuilding.

Independent implementation means that the Python checker uses different code
and coefficient/matrix algorithms. It does not assert independent human
peer review, unrelated underlying mathematical identities, or independent
model training. Formal verification and discovery priority are separate;
see [PRIOR_ART.md](PRIOR_ART.md).
