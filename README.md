# A Counterexample to Restricted Bell Real-Rootedness

**By Chris Ozols, with AI-assisted discovery, verification, and formalization.**

The restricted Bell polynomial **$B_{800,\le 5}(x)$ has a nonreal zero**.
This gives a counterexample to the real-rootedness assertion in Conjecture 6.4
of Moll, Ramírez, and Villamizar (2017). The result is formalized in
**Lean 4.28.0 with Mathlib v4.28.0**, starting from the actual finite-set-partition
counting definition.

> **Trust model.** The final theorems use only Lean's standard axioms
> `propext`, `Classical.choice`, and `Quot.sound`. All numerical equalities are
> checked by ordinary kernel computation. There is no `native_decide`, custom
> arithmetic oracle, or unproved coefficient-counting hypothesis. Python scripts
> generate proposed values and provide independent checks; the Lean proof does
> not depend on trusting their output.

[Readable proof](PROOF.md) · [Main Lean theorems](RestrictedBell/Final.lean) ·
[Exact-statement check](Verification.lean) · [Reproduce](REPRODUCE.md) ·
[Verification report](VERIFICATION_REPORT.md) · [Independent check](crosscheck/README.md) ·
[Provenance](PROVENANCE.md) · [Prior art](PRIOR_ART.md) · [Citation](CITATION.cff)

## The conjecture and what is proved

Let $S_{\le m}(n,k)$ count partitions of a labeled $n$-element set into $k$
nonempty blocks, with each block having at most $m$ elements. Define

```math
B_{n,\le m}(x)=\sum_{k=0}^{n}S_{\le m}(n,k)x^k.
```

[Conjecture 6.4, §6.1, printed page 14](https://arxiv.org/pdf/1707.08138v2#page=14)
asserts that these polynomials have only real, nonpositive zeros for positive
caps $m\notin\{3,4\}$. The pair $(n,m)=(800,5)$ satisfies that restriction and
has a nonreal zero.

| Statement | Lean declaration |
| --- | --- |
| $B_{800,\le5}$ has a nonreal complex root | `RestrictedBell.restrictedBell_800_5_nonreal` |
| The universal real-rootedness assertion is false | `RestrictedBell.realRootedness_conjecture_false` |
| $B_{800,\le5}$ is monic and nonzero, with degree exactly 800 | `RestrictedBell.countingBell_800_5_monic`, `RestrictedBell.countingBell_800_5_ne_zero`, `RestrictedBell.countingBell_800_5_natDegree` |
| Counting coefficients equal the restricted Stirling recurrence, for every $n,m,k$ | `RestrictedBell.countingBell_coeff_eq_stirling` |
| The counting and recurrence polynomials agree | `RestrictedBell.countingBell_eq_recurrenceBell` |
| The 39 required leading coefficients equal the exact certificate | `RestrictedBell.countingBell_certificate_bridge` |

The two final theorems are unconditional, and the polynomial is explicitly
proved nonzero. [Verification.lean](Verification.lean)
also states the nonreal-root result with the finite-partition sum written out,
and the negated conjecture with its quantifiers and cap restrictions explicit.

This is one counterexample. No smallest counterexample, classification of other
caps, historical priority, or first-discovery claim is made. The separate
log-concavity assertion in Conjecture 6.5 is not refuted by this result.

## Proof overview

1. **Remove the forced zero factor.** Every partition of 800 labels into blocks
   of size at most five has at least 160 blocks. Thus
   $B_{800,\le5}(x)=x^{160}Q(x)$, with $Q$ monic of degree 640.
2. **Compute leading coefficients exactly.** The combinatorial recurrence is
   proved by separating the block containing a distinguished label. It gives
   the leading 39 coefficients through 801 certified rows, checked in nine
   sequential Lean batches and connected directly to the integer certificate.
3. **Recover moments without approximating roots.** Newton's identities give
   the first 39 power sums $s_0,\ldots,s_{38}$ of the negatives of the roots of
   $Q$, counted with multiplicity, where $s_0=640$.
4. **Exhibit a negative quadratic form.** For
   $H=(s_{i+j})_{0\le i,j<20}$, an explicit integer vector $u$ satisfies
   $u^THu<0$. If all roots were real, this form would be a sum of 640 real
   squares and could not be negative.

The [original computational proof](original/README.md) uses a negative
Hankel determinant. The Lean proof uses the integer-vector certificate from
the [independent audit](crosscheck/README.md), avoiding a determinant algorithm
in the formal proof. Both certificates use exact arithmetic and allow repeated
roots. The profile-enumeration calculations remain as supplementary Lean checks;
the final theorem does not import that module.
[PROOF.md](PROOF.md) develops the argument and maps it to the Lean files.

## Reproduce the verification

On Linux x86_64 with Bash, Git, Python 3.9+, curl, tar, zstd, and coreutils:

```sh
git clone https://github.com/cozuya/restricted-bell-counterexample.git
cd restricted-bell-counterexample
bash scripts/install-lean.sh
export PATH="$PWD/.tools/lean-4.28.0-linux/bin:$PATH"
bash scripts/fetch-deps.sh
./verify.sh
python3 scripts/check-package.py
```

An existing local checkout can start at the installer step. With the pinned
Lean already on `PATH`, skip the installer.

`verify.sh` checks the pins and source hashes, deletes this project's build
outputs, rebuilds every project module, checks the explicit statements and thirteen
axiom inventories, then runs both Python verifiers and corruption controls.
Logs and a source-hashed machine-readable report are written to `.build/`.
See [REPRODUCE.md](REPRODUCE.md) for memory requirements and individual commands.

| Component | Pin |
| --- | --- |
| Lean | 4.28.0, `7e01a1bf5c70fc6167d49c345d3bf80596e9a79b` |
| Mathlib | v4.28.0, `8f9d9cff6bd728b17a24e163c9402775d9e6a365` |
| Transitive dependencies | Exact revisions in [lake-manifest.json](lake-manifest.json) |

The [GitHub Actions workflow](.github/workflows/verify.yml) is configured to
repeat verification on main-branch pushes, version tags, pull requests, manual
runs, and public visibility changes. The [verification report](VERIFICATION_REPORT.md)
distinguishes local evidence from hosted runs.

## Provenance and license

Chris Ozols directed the project. The package preserves the original
OpenAI-assisted computation, the subsequent independent exact-arithmetic audit,
and the later Lean source snapshot. The original recovery README predates the
Lean proof; its earlier status is explained in [PROVENANCE.md](PROVENANCE.md).

The public layout follows [gyires-permanent-4x4](https://github.com/cozuya/gyires-permanent-4x4).
The source and verification evidence support the mathematical result; they do
not establish discovery priority. [PRIOR_ART.md](PRIOR_ART.md) records the
bounded literature check and its limits.

Copyright 2026 Chris Ozols. Proof sources, scripts, certificates, and documentation
are licensed under the [Apache License, Version 2.0](LICENSE). Third-party
dependencies retain their own licenses.
