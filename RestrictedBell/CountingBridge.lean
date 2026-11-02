import RestrictedBell.ComputedRows.Batch8
import RestrictedBell.Certificate

namespace RestrictedBell

/-- The last checked recurrence row matches the original coefficient certificate. -/
theorem stirling_top_certificate (k : ℕ) (hk : k < 39) :
    (stirling 5 800 (800-k) : ℤ) = Certificate.c k := by
  have h := ComputedRows.row800_correct k hk
  rw [top, if_pos (by omega)] at h
  have hdata : ∀ r : Fin 39,
      ((ComputedRows.row800[r.val]?.getD 0 : ℕ) : ℤ) = Certificate.c r.val := by
    decide
  rw [← h]
  exact hdata ⟨k, hk⟩

/-- Actual set-partition coefficients equal the exact certificate directly,
using the proved counting recurrence and its checked final row. -/
theorem countingBell_certificate_bridge (k : ℕ) (hk : k < 39) :
    (countingBell 800 5).coeff (800-k) = (Certificate.c k : ℂ) := by
  rw [countingBell_coeff_eq_stirling]
  exact_mod_cast stirling_top_certificate k hk

end RestrictedBell
