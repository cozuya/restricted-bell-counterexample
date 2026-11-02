# Proof

The result is that $B_{800,\le5}$ has a nonreal complex zero. Here the coefficient
of $x^k$ in $B_{n,\le m}$ counts partitions of a labeled $n$-element set into
exactly $k$ nonempty blocks of size at most $m$.

## 1. From set partitions to exact coefficients

Write $S_m(n,k)$ for these counting numbers. For $n\ge1$ and $k\ge1$,

```math
S_m(n,k)=\sum_{j=0}^{\min(m,n)-1}\binom{n-1}{j}S_m(n-1-j,k-1),
\qquad S_m(0,k)=\begin{cases}1&k=0,\\0&k\ne0.\end{cases}
```

For a fixed distinguished label, choose its $j$ block-mates from the other
$n-1$ labels, then partition the complement into $k-1$ bounded blocks.
Removing that block and reinserting it are inverse constructions. Also,
$S_m(n,0)=0$ for $n>0$.

[Definition.lean](RestrictedBell/Definition.lean) defines `countingBell` directly
as one monomial for every bounded finite partition. [Profiles.lean](RestrictedBell/Profiles.lean)
identifies its coefficients with partition-fiber cardinalities.
[PartitionRecurrence.lean](RestrictedBell/PartitionRecurrence.lean) proves the
bijection and recurrence, and hence the equality of the counting and
recurrence-defined polynomials for every $n,m$.

For cap five, define $T(n,r)=S_5(n,n-r)$ when $r\le n$ and zero otherwise.
For $n\ge1$ the recurrence becomes

```math
T(n,r)=\sum_{j=0}^{\min(5,n)-1}\binom{n-1}{j}T(n-1-j,r-j)
\quad(0\le r<n),
```

where terms with $j>r$ are zero; for $r\ge n$, $T(n,r)=0$.
The initial row has $T(0,0)=1$ and all other entries zero. Each new row's
first 39 entries therefore needs only the preceding five rows' first 39 entries.

[TopRecurrence.lean](RestrictedBell/TopRecurrence.lean) proves this reduction and
`certify_top_row`. [ComputedRows/](RestrictedBell/ComputedRows) supplies the rows
$n=0,\ldots,800$ in nine dependent modules. Ordinary Lean `decide` checks every
row transition. The generator proposes values; the proof checks them.

[CountingBridge.lean](RestrictedBell/CountingBridge.lean) connects row 800
directly to the certificate through `countingBell_certificate_bridge`:

```lean
(countingBell 800 5).coeff (800-k) = (Certificate.c k : ℂ)
```

The additional finite block-profile sums in
[Coefficients.lean](RestrictedBell/Coefficients.lean) are retained as
supplementary checked calculations. Its `countingBell_profile_bridge` shows
agreement with the counting polynomial for these 39 coefficients. The final
theorem and its imports do not depend on that module or its natural-number
divisions. The counting recurrence establishes the required coefficients.

## 2. The quotient polynomial

A bounded partition of 800 labels with $k$ blocks satisfies $800\le5k$.
Thus every coefficient below degree 160 is zero, so

```math
B_{800,\le5}(x)=x^{160}Q(x).
```

The all-singleton partition is the unique partition with 800 blocks.
The formal certificate also verifies that this top coefficient is one.
There are no partitions with more than 800 blocks. Consequently $B$ is
monic of degree 800, and $Q$ is monic of degree 640.

Let

```math
Q(x)=x^{640}+c_1x^{639}+\cdots+c_{640},\qquad c_0=1.
```

The required $c_r$ are precisely $T(800,r)$ for $0\le r\le38$.
For example,

```math
(c_0,c_1,c_2,c_3)=(1,319600,50901893000,5386640033279400).
```

The factor and degree arguments are formalized in
[Definition.lean](RestrictedBell/Definition.lean) and
[Counterexample.lean](RestrictedBell/Counterexample.lean).
[Final.lean](RestrictedBell/Final.lean) also exports
`countingBell_800_5_monic`, `countingBell_800_5_ne_zero`, and
`countingBell_800_5_natDegree`, so nonzeroness and degree can be inspected and
audited directly alongside the nonreal-root theorem.

## 3. Newton identities and the moment matrix

Let $z_1,\ldots,z_{640}$ be the complex roots of $Q$, with algebraic multiplicity,
and set $\lambda_\ell=-z_\ell$. Define $s_0=640$ and
$s_k=\sum_{\ell=1}^{640}\lambda_\ell^k$ for $k\ge1$.
Newton's identities give

```math
s_k=\sum_{i=1}^{k-1}(-1)^{i+1}c_i s_{k-i}+(-1)^{k+1}k c_k
\qquad(1\le k\le38).
```

Thus the certified leading coefficients determine all 39 required moments.
The first four are $(640,319600,340374000,458627438200)$.
Form the integer Hankel matrix

```math
H=(s_{i+j})_{0\le i,j<20}.
```

[Newton.lean](RestrictedBell/Newton.lean) specializes Mathlib's Newton identities.
[Obstruction.lean](RestrictedBell/Obstruction.lean) obtains the complete complex
root multiset, applies Vieta's formulas, and proves that these roots have the
certified moments. Repeated roots are included.

## 4. An exact obstruction to real roots

If all $z_\ell$ were real, all $\lambda_\ell$ would be real. For every
$u=(u_0,\ldots,u_{19})\in\mathbb{R}^{20}$,

```math
u^THu=\sum_{\ell=1}^{640}\left(\sum_{i=0}^{19}u_i\lambda_\ell^i\right)^2\ge0.
```

[Moments.lean](RestrictedBell/Moments.lean) proves this identity and implication.
But the explicit integer vector in
[crosscheck/independent-certificate.json](crosscheck/independent-certificate.json)
has $u^THu<0$. Its 20 entries have at most 447 decimal digits in absolute
value; the negative quadratic-form value has 897 digits in absolute value.
[Certificate.lean](RestrictedBell/Certificate.lean) records the full integers
and checks the exact quadratic-form value and every Newton equation.

This contradiction shows that $Q$ has a nonreal zero, which is also a zero
of $B_{800,\le5}$. [Final.lean](RestrictedBell/Final.lean) applies the proved
coefficient bridge and states the unconditional counterexample and refutation.

The original certificate instead uses

```math
-8\cdot10^{1087}<\det H<-7\cdot10^{1087}<0.
```

Real roots would make $H$ positive semidefinite, forcing a nonnegative
determinant. Both Python implementations verify this 1088-digit negative
determinant. The Lean proof uses the negative quadratic form, so it needs
neither determinant elimination nor a floating-point root calculation.

## 5. Scope and trust

The witness uses cap five, which is admissible in the conjecture's exclusion
of caps three and four. One witness suffices to refute the universal assertion.
Nothing here establishes the smallest witness, the number or location of
nonreal roots, or a classification of caps. The failure of real-rootedness
does not by itself imply a failure of log-concavity.

All active Lean numerical checks are ordinary `decide` or proof tactics whose
proof terms are kernel-checked. The final declarations have exactly the
standard axiom set `propext`, `Classical.choice`, `Quot.sound`. The Python
implementations and their generators are outside the formal proof's trust
boundary. See [VERIFICATION_REPORT.md](VERIFICATION_REPORT.md) for the actual
rebuild and axiom audit.
