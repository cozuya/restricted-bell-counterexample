# Independent exact-arithmetic check

[independent_check.py](independent_check.py) and
[independent-certificate.json](independent-certificate.json) are preserved
byte-for-byte from the independent pre-Lean audit. The checker imports no
original proof code. It computes:

1. The leading 39 coefficients by direct enumeration of block-size profiles.
2. The 39 moments by formal-series inversion and a logarithmic derivative.
3. An exact rational factorization of the 20 by 20 Hankel matrix, checking
   every reconstructed entry and its negative determinant.
4. A primitive integer vector whose Hankel quadratic form is negative.

The coefficient and matrix algorithms differ from those in the original
verifier. The power-sum identities have the same mathematical basis.
Neither Python implementation is a dependency of the Lean proof.

From the repository root, run:

```sh
bash crosscheck/run.sh
```

This executes both Python verifiers, compares the new independent certificate
byte-for-byte with the preserved one, and checks that the independent verifier
rejects both a changed coefficient and a reversed determinant sign. These
negative controls test certificate comparison; they are not a separate
mathematical proof or a comprehensive test suite.

The scripts use Python 3.9 or later, with assertions enabled, and only its
standard library. Fresh output goes into `.build/`. The earlier audit report is
preserved in [provenance/independent/AUDIT.md](../provenance/independent/AUDIT.md).
Its relative `input/` and `verification/` paths refer to its original bundle;
[PROVENANCE.md](../PROVENANCE.md) maps them to this package.
