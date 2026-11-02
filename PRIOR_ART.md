# Prior art and scope

## Source of the conjecture

Victor H. Moll, José L. Ramírez, and Diego Villamizar,
*Combinatorial and Arithmetical Properties of the Restricted and Associated
Bell and Factorial Numbers*, arXiv:1707.08138 (2017).

- [arXiv record and revision history](https://arxiv.org/abs/1707.08138)
- [Version 1, Conjecture 6.4, printed page 14](https://arxiv.org/pdf/1707.08138v1#page=14)
- [Version 2, Conjecture 6.4, printed page 14](https://arxiv.org/pdf/1707.08138v2#page=14)

Both arXiv versions state the same real, nonpositive-root conjecture for the
restricted Bell polynomials when the block-size cap is neither three nor four.
The definition bounds the size of each block, rather than the number of blocks.
The witness here is the admissible pair $(800,5)$.

The arXiv record dates the first submission to July 25, 2017 and the revision
to July 31, 2017. Those submission dates, rather than a PDF's compilation date,
identify the versions cited here. The current package checked both arXiv
statements. It does not claim to have checked a final publisher version.

## Scope of the counterexample

The result supplies one exact witness with a completed Lean proof. It neither
asserts a minimal value of $n$ nor classifies caps. It does not settle the
separate log-concavity assertion in Conjecture 6.5. Restricted Bell terminology
also appears for other restrictions; a result using that name alone need not
address this conjecture.

The mathematical proof and machine verification can be assessed from
[PROOF.md](PROOF.md), [Verification.lean](Verification.lean), and the
[verification report](VERIFICATION_REPORT.md).

## Bounded search and novelty

On November 2, 2026, package preparation searched combinations including
`"restricted Bell polynomials" "real"`,
`"Conjecture 6.4" "Moll" Bell`,
`"restricted Bell" "nonreal"`, and the authors' names with the conjecture number.
These queries did not locate an earlier exact-scope refutation. The retained
[independent audit](provenance/independent/AUDIT.md) also reports a bounded
search with no earlier refutation located.

This is a limited web search, with noisy terminology and incomplete indexing.
It is not a comprehensive review of citing literature, inaccessible publications,
or unpublished work. No novelty, first-discovery, priority, or official
problem-list closure claim is made.
