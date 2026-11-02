import Mathlib
import Mathlib.Data.Real.Basic
import Mathlib.Algebra.BigOperators.Ring.Finset
import Mathlib.Tactic.Ring

namespace RestrictedBell
open scoped BigOperators

/-- The quadratic form of finitely many power moments is a sum of squares.
The indexing permits repeated values, hence repeated roots. -/
theorem hankel_eq_sum_sq {d N : ℕ} (u : Fin d → ℝ) (r : Fin N → ℝ) :
    (∑ i, ∑ j, u i * (∑ l, r l ^ (i.val + j.val)) * u j) =
      ∑ l, (∑ i, u i * r l ^ i.val) ^ 2 := by
  simp_rw [Finset.mul_sum, Finset.sum_mul, pow_add]
  calc
    _ = ∑ i, ∑ l, ∑ j, u i * (r l ^ i.val * r l ^ j.val) * u j := by
      apply Finset.sum_congr rfl
      intro i hi
      exact Finset.sum_comm
    _ = ∑ l, ∑ i, ∑ j, u i * (r l ^ i.val * r l ^ j.val) * u j :=
      Finset.sum_comm
    _ = _ := by
      apply Finset.sum_congr rfl
      intro l hl
      rw [pow_two, Finset.sum_mul]
      simp_rw [Finset.mul_sum]
      apply Finset.sum_congr rfl
      intro i hi
      apply Finset.sum_congr rfl
      intro j hj
      ring

/-- Any finite family of real numbers has nonnegative Hankel forms. -/
theorem hankel_nonneg {d N : ℕ} (u : Fin d → ℝ) (r : Fin N → ℝ) :
    0 ≤ ∑ i, ∑ j, u i * (∑ l, r l ^ (i.val + j.val)) * u j := by
  rw [hankel_eq_sum_sq]
  exact Finset.sum_nonneg fun _ _ => sq_nonneg _

/-- A negative quadratic form excludes a real power-sum representation. -/
theorem no_real_moment_representation {d N : ℕ} (s : ℕ → ℝ) (u : Fin d → ℝ)
    (hneg : (∑ i, ∑ j, u i * s (i.val + j.val) * u j) < 0) :
    ¬ ∃ r : Fin N → ℝ, ∀ k < 2 * d - 1, s k = ∑ l, r l ^ k := by
  rintro ⟨r, hr⟩
  have heq : (∑ i, ∑ j, u i * s (i.val + j.val) * u j) =
      ∑ i, ∑ j, u i * (∑ l, r l ^ (i.val + j.val)) * u j := by
    apply Finset.sum_congr rfl
    intro i hi
    apply Finset.sum_congr rfl
    intro j hj
    rw [hr _ (by have := i.isLt; have := j.isLt; omega)]
  rw [heq] at hneg
  exact (not_lt_of_ge (hankel_nonneg u r)) hneg
end RestrictedBell
