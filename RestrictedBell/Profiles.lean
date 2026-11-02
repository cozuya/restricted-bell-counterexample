import RestrictedBell.Definition

namespace RestrictedBell
open scoped BigOperators

/-- Number of blocks of a specified size, in an actual finite partition. -/
def blockProfile {α : Type*} [DecidableEq α] {s : Finset α}
    (p : Finpartition s) (j : ℕ) : ℕ :=
  (p.parts.filter (fun b => b.card = j)).card

theorem blockProfile_zero {α : Type*} [DecidableEq α] {s : Finset α}
    (p : Finpartition s) : blockProfile p 0 = 0 := by
  simp [blockProfile, Finset.card_eq_zero, p.empty_notMem_parts]

theorem profile_blocks {α : Type*} [DecidableEq α] {s : Finset α}
    (p : Finpartition s) (m : ℕ) (hm : ∀ b ∈ p.parts, b.card ≤ m) :
    ∑ j ∈ Finset.range (m+1), blockProfile p j = p.parts.card := by
  simp only [blockProfile, Finset.card_filter]
  rw [Finset.sum_comm]
  conv_rhs => rw [show p.parts.card = ∑ _ ∈ p.parts, (1:ℕ) by simp]
  apply Finset.sum_congr rfl
  intro b hb
  simp [Finset.sum_ite_eq, Finset.mem_range, Nat.lt_succ_of_le (hm b hb)]

theorem profile_labels {α : Type*} [DecidableEq α] {s : Finset α}
    (p : Finpartition s) (m : ℕ) (hm : ∀ b ∈ p.parts, b.card ≤ m) :
    ∑ j ∈ Finset.range (m+1), j * blockProfile p j = s.card := by
  simp only [blockProfile, Finset.card_filter, Finset.mul_sum]
  rw [Finset.sum_comm, ← p.sum_card_parts]
  apply Finset.sum_congr rfl
  intro b hb
  simp [mul_ite, Finset.sum_ite_eq, Finset.mem_range, Nat.lt_succ_of_le (hm b hb)]

/-- The deficit equation used to enumerate the certificate's profiles. -/
theorem profile_deficit {n r : ℕ} (p : BoundedPartition n 5)
    (hr : r ≤ n) (hb : p.val.parts.card = n-r) :
    blockProfile p.val 2 + 2*blockProfile p.val 3 +
      3*blockProfile p.val 4 + 4*blockProfile p.val 5 = r := by
  have hblocks := profile_blocks p.val 5 p.property
  have hlabels := profile_labels p.val 5 p.property
  norm_num [Finset.sum_range_succ, blockProfile_zero] at hblocks hlabels
  omega

/-- Polynomial coefficients are literal cardinalities of partition fibers. -/
theorem countingBell_coeff_eq_card (n m k : ℕ) :
    (countingBell n m).coeff k =
      (Fintype.card {p : BoundedPartition n m // p.val.parts.card = k} : ℂ) := by
  classical
  simp [countingBell, Polynomial.finset_sum_coeff, Polynomial.coeff_X_pow,
    Fintype.card_subtype, eq_comm]

end RestrictedBell
