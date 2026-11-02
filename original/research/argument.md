# A counterexample at block-size cap five

**Conclusion.** The asserted universal real-rootedness is false. The admissible pair is
\[
(n,m)=(800,5).
\]
The polynomial \(B_{800,\le5}\) has a nonreal zero. No assertion of minimality is made.

The question appears as Conjecture 6.4, §6.1, printed p.14, in [Moll, Ramírez and Villamizar, *Combinatorial and Arithmetical Properties of the Restricted and Associated Bell and Factorial Numbers*](https://arxiv.org/pdf/1707.08138v1#page=14).

## 1. Exact specification of the polynomial

A compact complete coefficient specification is
\[
B(x)=800!\sum_{\substack{a_1,\ldots,a_5\ge0\\
a_1+2a_2+3a_3+4a_4+5a_5=800}}
\frac{x^{a_1+\cdots+a_5}}
{\prod_{j=1}^5 (j!)^{a_j}a_j!}.
\]
Here \(a_j\) is the number of blocks of size \(j\): divide the number of label orderings by the orders within blocks and by the orders of equal-sized blocks. Thus this is exactly the required counting polynomial, not a polynomial for a different restriction.

There are no partitions into fewer than 160 blocks, and
\[
[x^{160}]B(x)=\frac{800!}{(5!)^{160}160!}>0.
\]
Consequently \(B(x)=x^{160}Q(x)\), where \(Q\) is monic of degree 640. Every coefficient of \(Q\) is positive: every integer number of blocks between 160 and 800 can be realized with block sizes between 1 and 5. In particular, positive real roots are impossible.

The verifier constructs **all** coefficients of \(B\) by
\[
S_5(t,k)=\sum_{j=1}^{\min(5,t)}\binom{t-1}{j-1}S_5(t-j,k-1),
\qquad S_5(0,0)=1.
\]
This follows by selecting the block containing label \(t\). At each row it checks the separate differential identity
\[
B_t=x(B_{t-1}+B'_{t-1})-\binom{t-1}{5}xB_{t-6},
\]
with the last term omitted for \(t\le5\). The first terms insert the new label or create a singleton; the subtraction removes insertions into full five-element blocks.

Finally, all 801 coefficients of the row at \(t=800\) are independently checked against
\[
S_5(800,k)=\frac{800!}{k!}[z^{800}]
\left(z+\frac{z^2}{2}+\frac{z^3}{6}+\frac{z^4}{24}+\frac{z^5}{120}\right)^k.
\]
The latter calculation uses the integer polynomial \(120z+60z^2+20z^3+5z^4+z^5\) and exact divisions.

## 2. Necessary moment-matrix condition

Write
\[
Q(x)=x^{640}+c_1x^{639}+\cdots+c_{640},\qquad c_0=1,
\]
and let \(\lambda_1,\ldots,\lambda_{640}\) be the negatives of its zeros, counted with algebraic multiplicity. Define
\[
s_0=640,\qquad s_k=\sum_{\ell=1}^{640}\lambda_\ell^k\quad(k\ge1).
\]
Newton's identities give, for \(1\le k\le38\),
\[
s_k=\sum_{i=1}^{k-1}(-1)^{i+1}c_i s_{k-i}
       +(-1)^{k+1}k c_k.
\]
Thus these sums require only the first 39 leading coefficients, without approximating any zeros. For orientation,
\[
(c_0,c_1,c_2,c_3)=(1,319600,50901893000,5386640033279400),
\]
\[
(s_0,s_1,s_2,s_3)=(640,319600,340374000,458627438200).
\]
Form the integer matrix
\[
H=(s_{i+j})_{0\le i,j\le19}.
\]
If all zeros of \(Q\) were real, all \(\lambda_\ell\) would be real, and for every real vector \(u=(u_0,\ldots,u_{19})\),
\[
u^THu=\sum_{\ell=1}^{640}
\left(\sum_{i=0}^{19}u_i\lambda_\ell^i\right)^2\ge0.
\]
Hence \(H\) would be positive semidefinite and \(\det H\ge0\). This necessity allows repeated zeros and requires no squarefreeness assumption.

## 3. Exact violation and its verification

The exact arithmetic calculation gives
\[
-8\cdot10^{1087}<\det H<-7\cdot10^{1087}<0.
\]
The full 1088-digit absolute value, all \(c_0,\ldots,c_{38}\), and all \(s_0,\ldots,s_{38}\) are in `certificates/witness.json`. The first 19 leading principal determinants of \(H\) are positive; the twentieth is negative.

`code/check.py` is a standalone standard-library Python verifier. Run from the artifact root:

```
python3 code/check.py
```

It constructs the complete polynomial, checks both other coefficient identities, strips the zero factor, calculates the moments by Newton's identities, and calculates the determinant in **two** exact ways:

1. Fraction-free Bareiss elimination, checking every exact division. Without swaps, its successive pivots are the leading principal determinants.
2. Ordinary Gaussian row elimination over `fractions.Fraction`, multiplying the pivots to obtain the determinant.

All relevant pivots are nonzero, and both results agree with the supplied certificate. The asserted bound above is also checked using integers. The script was executed successfully in this attempt, and was rerun successfully with the stored certificate present. No floating-point root calculation is used.

The negative determinant contradicts the necessary condition in §2. Therefore \(Q\), and hence \(B_{800,\le5}\), has a nonreal zero. Since \(5\notin\{3,4\}\), this refutes the exact universal assertion.
