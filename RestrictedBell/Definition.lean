import Mathlib
import Mathlib.Order.Partition.Finpartition
import Mathlib.Algebra.Polynomial.Roots
import Mathlib.Data.Nat.Choose.Basic
import Mathlib.Data.Complex.Basic

namespace RestrictedBell
open scoped BigOperators

/-- Restricted Stirling numbers by the block-containing-the-last-label recurrence. -/
def stirling (m : ℕ) : ℕ → ℕ → ℕ
  | 0, k => if k = 0 then 1 else 0
  | _ + 1, 0 => 0
  | n + 1, k + 1 => ∑ j ∈ Finset.range (min m (n + 1)),
      n.choose j * stirling m (n - j) k
termination_by n _ => n

/-- The recurrence-defined polynomial. Its equivalence to `countingBell` is proved in `PartitionRecurrence.lean`. -/
noncomputable def recurrenceBell (n m : ℕ) : Polynomial ℂ :=
  ∑ k ∈ Finset.range (n + 1), Polynomial.monomial k (stirling m n k : ℂ)

/-- Actual finite partitions of the labeled set, with bounded block sizes. -/
def BoundedPartition (n m : ℕ) :=
  {p : Finpartition (Finset.univ : Finset (Fin n)) // ∀ b ∈ p.parts, b.card ≤ m}

noncomputable instance (n m : ℕ) : Fintype (BoundedPartition n m) := by
  classical
  unfold BoundedPartition
  infer_instance

/-- Counting definition: one monomial for each restricted set partition. -/
noncomputable def countingBell (n m : ℕ) : Polynomial ℂ :=
  ∑ p : BoundedPartition n m, Polynomial.X ^ p.val.parts.card

/-- The counterexample proposition, proved unconditionally in `Final.lean`. -/
def CounterexampleStatement : Prop :=
  ∃ z : ℂ, (countingBell 800 5).IsRoot z ∧ z.im ≠ 0

/-- Every bounded partition has enough blocks to hold all labels. -/
theorem labels_le_cap_mul_blocks {n m : ℕ} (p : BoundedPartition n m) :
    n ≤ m * p.val.parts.card := by
  have h := Finset.sum_le_sum p.property
  have hcard := p.val.sum_card_parts
  simpa [hcard, mul_comm] using h

/-- The forced zero factor follows directly from the counting definition. -/
theorem countingBell_low_coeff (k : ℕ) (hk : k < 160) :
    (countingBell 800 5).coeff k = 0 := by
  classical
  simp only [countingBell, Polynomial.finset_sum_coeff]
  apply Finset.sum_eq_zero
  intro p hp
  have h := labels_le_cap_mul_blocks p
  rw [Polynomial.coeff_X_pow]
  split_ifs with heq
  · omega
  · rfl

theorem countingBell_has_forced_factor :
    ∃ q : Polynomial ℂ, countingBell 800 5 = Polynomial.X ^ 160 * q := by
  apply Polynomial.X_pow_dvd_iff.mpr
  exact countingBell_low_coeff

theorem countingBell_degree_le (n m : ℕ) : (countingBell n m).natDegree ≤ n := by
  classical
  apply Polynomial.natDegree_le_iff_coeff_eq_zero.mpr
  intro k hk
  simp only [countingBell, Polynomial.finset_sum_coeff]
  apply Finset.sum_eq_zero
  intro p hp
  have h := p.val.card_parts_le_card
  simp only [Finset.card_univ, Fintype.card_fin] at h
  rw [Polynomial.coeff_X_pow, if_neg (by omega)]

end RestrictedBell
