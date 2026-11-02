import RestrictedBell.PartitionRecurrence

namespace RestrictedBell
open scoped BigOperators

theorem stirling_above (m : ℕ) : ∀ n k, n < k → stirling m n k = 0 := by
  intro n
  induction n using Nat.strong_induction_on with
  | h n ih =>
    intro k hk
    cases n with
    | zero => simp [stirling, show k ≠ 0 by omega]
    | succ n =>
      cases k with
      | zero => omega
      | succ k =>
        rw [stirling]
        apply Finset.sum_eq_zero
        intro j hj
        rw [ih (n-j) (by omega) k (by omega), mul_zero]

/-- Deficit-indexed coefficients, extended by zero beyond their row. -/
def top (n r : ℕ) : ℕ := if r ≤ n then stirling 5 n (n-r) else 0

/-- One step of the leading-coefficient recurrence; only the preceding five rows are used. -/
def topStep (n : ℕ) (prev : ℕ → List ℕ) (r : ℕ) : ℕ :=
  if r < n then ∑ j ∈ Finset.range (min 5 n),
    if j ≤ r then (n-1).choose j * (prev j)[r-j]?.getD 0 else 0
  else 0

theorem top_zero (r : ℕ) : top 0 r = if r = 0 then 1 else 0 := by
  simp [top, stirling]

theorem top_succ (n r : ℕ) : top (n+1) r =
    if r < n+1 then ∑ j ∈ Finset.range (min 5 (n+1)),
      if j ≤ r then n.choose j * top (n-j) (r-j) else 0
    else 0 := by
  by_cases h : r < n+1
  · rw [top, if_pos (by omega), if_pos h]
    have hk : n+1-r = (n-r)+1 := by omega
    rw [hk, stirling]
    apply Finset.sum_congr rfl
    intro j hj
    have hjn : j ≤ n := by simp only [Finset.mem_range, lt_min_iff] at hj; omega
    by_cases hjr : j ≤ r
    · rw [if_pos hjr, top, if_pos (by omega)]
      congr 2
      omega
    · rw [if_neg hjr, stirling_above 5 (n-j) (n-r) (by omega), mul_zero]
  · rw [if_neg h, top]
    split_ifs with hr
    · have he : n+1-r = 0 := by omega
      rw [he, stirling]
    · rfl

/-- A row of proposed values is certified using only certified predecessor rows.
The transition equality is checked separately by exact kernel computation. -/
theorem certify_top_row (n : ℕ) (hn : 0 < n) (v : List ℕ) (prev : ℕ → List ℕ)
    (hp : ∀ j < min 5 n, ∀ r < 39, (prev j)[r]?.getD 0 = top (n-1-j) r)
    (hv : ∀ r : Fin 39, v[r.val]?.getD 0 = topStep n prev r.val) :
    ∀ r < 39, v[r]?.getD 0 = top n r := by
  intro r hr
  rw [hv ⟨r, hr⟩]
  obtain ⟨n, rfl⟩ := Nat.exists_eq_succ_of_ne_zero (by omega : n ≠ 0)
  rw [top_succ]
  unfold topStep
  split_ifs with h
  · apply Finset.sum_congr rfl
    intro j hj
    split_ifs with hjr
    · rw [hp j (Finset.mem_range.mp hj) (r-j) (by omega)]
      rfl
    · rfl
  · rfl
end RestrictedBell
