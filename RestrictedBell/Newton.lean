import Mathlib.RingTheory.MvPolynomial.Symmetric.NewtonIdentities
import Mathlib.RingTheory.Polynomial.Vieta
import Mathlib

namespace RestrictedBell
open scoped BigOperators

def elementary {N : ℕ} (r : Fin N → ℂ) (k : ℕ) : ℂ :=
  (Finset.univ.val.map r).esymm k

/-- Newton's identities specialized to a finite indexed family, with multiplicities. -/
theorem tuple_newton {N : ℕ} (r : Fin N → ℂ) (k : ℕ) (hk : 0 < k) :
    (∑ l, r l ^ k) = (-1 : ℂ) ^ (k+1) * k * elementary r k -
      ∑ a ∈ (Finset.antidiagonal k).filter (fun a => a.1 ∈ Set.Ioo 0 k),
        (-1 : ℂ) ^ a.1 * elementary r a.1 * ∑ l, r l ^ a.2 := by
  have h := congrArg (MvPolynomial.aeval r)
    (MvPolynomial.psum_eq_mul_esymm_sub_sum (Fin N) ℂ k hk)
  simpa only [map_sub, map_mul, map_pow, map_sum, map_neg, map_one, map_natCast,
    MvPolynomial.aeval_esymm_eq_multiset_esymm, MvPolynomial.psum,
    MvPolynomial.aeval_X, elementary] using h
end RestrictedBell
