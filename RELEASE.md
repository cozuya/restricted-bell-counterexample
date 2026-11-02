# Initial release: v1.0.0

Tag: **`v1.0.0`**. The single initial commit contains the complete
proof, readable documentation, verification infrastructure, preserved source
records, and completed local evidence.

The repository description and 13 topics are recorded in
[.github/repository.json](.github/repository.json). GitHub does not apply that
file automatically. The annotated Git tag identifies this source version;
repository visibility is managed separately by the owner.

## Release notes

The restricted Bell polynomial $B_{800,\le5}$ has a nonreal complex root,
refuting the real-rootedness assertion of Moll–Ramírez–Villamizar Conjecture 6.4.

The package contains an unconditional Lean 4.28.0/Mathlib v4.28.0 proof using
only the standard axioms, including a direct counting-to-certificate bridge,
explicit monicity/nonzero/degree results, and exact integer certificate checks.
It also includes the original computational
refutation, an independent Python checker, reproducible build and audit
scripts, source hashes, and recorded verification evidence. No smallest-witness
or novelty claim is made.

## Verification

The completed local run is documented in
[VERIFICATION_REPORT.md](VERIFICATION_REPORT.md). To check the packaged evidence:

```sh
python3 scripts/check-package.py
```

For a fresh Lean rebuild and certificate verification, follow
[REPRODUCE.md](REPRODUCE.md). Subsequent hosted runs are available on the
[Actions page](https://github.com/cozuya/restricted-bell-counterexample/actions).
