# Independent audit: ColdHarvest Problem 20

**Audit date:** November 2, 2026  
**Input:** `problem-20-openai-refutation-20261102-proof.zip`  
**Input ZIP SHA-256:** `10dd26c3125965ce3361b557fc4d05dae2a4cc8f6593c32c5dc11820e98f70dc`

## Verdict

The supplied exact-arithmetic refutation checks out. The polynomial
`B_(800,<=5)(x)` has a nonreal zero. Its use of block-size cap 5 directly
contradicts the universal statement of Conjecture 6.4 in both arXiv versions
of Moll, Ramirez, and Villamizar, *Combinatorial and Arithmetical Properties
of the Restricted and Associated Bell and Factorial Numbers*.

This audit independently reproduces the mathematical certificate. It does
not establish novelty or provide a Lean/kernel-checked formalization.
No original run, database entry, provider session, or repository was altered.

## Exact scope checked against the source

The source counts set partitions with every block of size at most m. It
asserts that the corresponding polynomial has only real, nonpositive zeros
when m is neither 3 nor 4. The witness uses n=800, m=5 and the same definition.
Both source PDFs were inspected at printed page 14, Section 6.1, including
a rendered screenshot of each conjecture statement.

Primary sources:
- https://arxiv.org/abs/1707.08138 (first submission July 25, 2017)
- https://arxiv.org/pdf/1707.08138v1 (Conjecture 6.4, printed page 14)
- https://arxiv.org/pdf/1707.08138v2 (same conjecture and scope)

The publisher PDF returned HTTP 403. The verdict therefore rests on the
directly inspected arXiv statements, not an independently inspected copy
of the final journal version. A bounded targeted web search found no earlier
exact-scope refutation; this is not a comprehensive novelty clearance.

## Supplied verifier: actually executed

After inspecting `input/code/check.py`, the audit ran it under ordinary
Python with assertions enabled. It passed in 1.59 seconds in this environment.
The complete output is `verification/supplied-verifier.log`.

The run checked:
1. All coefficient rows through n=800 via the block-containing-n recurrence,
   cross-checked against the differential recurrence.
2. All 801 final coefficients against a separate generating-function calculation.
3. The forced factor x^160 and the monic quotient Q of degree 640.
4. The 39 leading coefficients and 39 power sums in the certificate.
5. The order-20 Hankel determinant by both integer Bareiss elimination and
   rational Gaussian elimination, with agreement to the supplied exact integer.

The first 19 leading principal minors are positive; the twentieth is negative:

    -8 * 10^1087 < det(H) < -7 * 10^1087 < 0.

## Independent implementation: actually executed

`verification/independent_check.py` imports no supplied code. It recomputes
the decisive quantities before reading the supplied certificate for comparison.

### Coefficients: direct block-type enumeration

For the coefficient of x^(800-r), enumerate all nonnegative a2,a3,a4,a5 with

    a2 + 2*a3 + 3*a4 + 4*a5 = r.

Writing t=2*a2+3*a3+4*a4+5*a5, each type contributes exactly

    (800)_t / ((2!)^a2 a2! (3!)^a3 a3! (4!)^a4 a4! (5!)^a5 a5!),

where (800)_t is a falling factorial and the remaining elements are singletons.
The implementation checks every division is exact. All 39 leading coefficients
agree with the supplied certificate. This is different code and a different
coefficient-construction route from both supplied coefficient algorithms.

### Moments: formal-series inversion

For Q(x)=x^640+c1*x^639+..., form

    F(z) = 1-c1*z+c2*z^2-... = product_l (1-lambda_l*z),

where lambda_l are the negatives of Q's roots, with multiplicity. Compute the
inverse series of F and then

    -z F'(z)/F(z) = sum_(k>=1) s_k*z^k.

All 39 moments, including s0=640, agree with the supplied certificate.
This is an independent implementation of the same underlying power-sum identity,
not a claim that the identity is mathematically unrelated to Newton's identities.

### Matrix: exact rational LDL-transpose factorization

Set H[i,j]=s_(i+j), 0<=i,j<20. The audit constructs H=L D L^T with rational
arithmetic, and independently checks all 400 entries of the reconstruction.
The first 19 diagonal entries of D are positive and the last is negative.
The product of the diagonal entries exactly matches the supplied 1088-digit
negative determinant.

### Additional direct negative-vector certificate

The audit solves L^T u=e19 and clears denominators and the common factor,
producing a primitive integer vector v of length 20. Direct integer arithmetic
verifies v^T H v<0. The vector and its exact quadratic-form value are stored
in `verification/independent-certificate.json`.

The largest vector entry has 447 decimal digits in absolute value; the negative
quadratic form has 897 digits in absolute value. This provides an alternative
verification target that does not require accepting a determinant algorithm.
The independent implementation completed in 0.062 seconds in this environment.

## Why this proves a nonreal zero

If every zero of Q were real, every lambda_l would be real. For every real
vector v, define P(t)=sum_(i=0)^19 v_i*t^i. Then

    v^T H v = sum_(l=1)^640 P(lambda_l)^2 >= 0.

The checked integer vector gives v^T H v<0, a contradiction. Equivalently,
H would be positive semidefinite and could not have a negative determinant.
The argument allows repeated roots and uses no numerical root approximations.
Since B_(800,<=5)=x^160 Q, a nonreal zero of Q is also a nonreal zero of B.

No minimality claim and no classification of other caps are needed for this
refutation. The supplied preliminary sweeps and asymptotic search heuristic
were not rerun; neither is a premise of the certificate.

## Run-state limits

The uploaded README says the original two-provider invocation is paused and
its cross-provider critique has not run. This audit does not change that status.
The archive contains no Lean formalization, and none was performed in this audit.
Novelty remains a separate, unresolved status question.

## Reproduction

From this bundle's root:

```sh
python3 input/code/check.py
python3 verification/independent_check.py input/certificates/witness.json \
  --out verification/independent-certificate-rerun.json
```

Both checkers use only Python's standard library. Run without `-O` so that
assertions remain active. The bundle preserves the uploaded files under `input/`
and keeps the added audit and certificates separate under `verification/`.
