import RestrictedBell.Certificate
import RestrictedBell.CountingBridge
import Mathlib.Data.Nat.Factorial.Basic

namespace RestrictedBell
open scoped BigOperators
set_option maxRecDepth 100000
set_option maxHeartbeats 0

/-- Numerator for a block profile with the unlisted elements singleton blocks. -/
def profileNumerator (n a₂ a₃ a₄ a₅ : ℕ) : ℕ :=
  n.descFactorial (2*a₂ + 3*a₃ + 4*a₄ + 5*a₅)

def profileDenominator (a₂ a₃ a₄ a₅ : ℕ) : ℕ :=
  2^a₂ * a₂.factorial * 6^a₃ * a₃.factorial *
    24^a₄ * a₄.factorial * 120^a₅ * a₅.factorial

/-- Efficient finite enumeration of profiles of deficit `r`.
For `n = 800` and `r < 39`, `countingBell_profile_bridge` below connects this
supplementary calculation to the counting polynomial. The final counterexample
uses the direct certificate bridge and does not depend on this module. -/
def profileCoefficient (n r : ℕ) : ℕ :=
  ∑ a₅ ∈ Finset.range (r / 4 + 1),
  ∑ a₄ ∈ Finset.range ((r - 4*a₅) / 3 + 1),
  ∑ a₃ ∈ Finset.range ((r - 4*a₅ - 3*a₄) / 2 + 1),
    let a₂ := r - 4*a₅ - 3*a₄ - 2*a₃
    profileNumerator n a₂ a₃ a₄ a₅ / profileDenominator a₂ a₃ a₄ a₅

theorem profile_coefficient_0 : (profileCoefficient 800 0 : ℤ) = Certificate.c 0 := by decide

theorem profile_coefficient_1 : (profileCoefficient 800 1 : ℤ) = Certificate.c 1 := by decide

theorem profile_coefficient_2 : (profileCoefficient 800 2 : ℤ) = Certificate.c 2 := by decide

theorem profile_coefficient_3 : (profileCoefficient 800 3 : ℤ) = Certificate.c 3 := by decide

theorem profile_coefficient_4 : (profileCoefficient 800 4 : ℤ) = Certificate.c 4 := by decide

theorem profile_coefficient_5 : (profileCoefficient 800 5 : ℤ) = Certificate.c 5 := by decide

theorem profile_coefficient_6 : (profileCoefficient 800 6 : ℤ) = Certificate.c 6 := by decide

theorem profile_coefficient_7 : (profileCoefficient 800 7 : ℤ) = Certificate.c 7 := by decide

theorem profile_coefficient_8 : (profileCoefficient 800 8 : ℤ) = Certificate.c 8 := by decide

theorem profile_coefficient_9 : (profileCoefficient 800 9 : ℤ) = Certificate.c 9 := by decide

theorem profile_coefficient_10 : (profileCoefficient 800 10 : ℤ) = Certificate.c 10 := by decide

theorem profile_coefficient_11 : (profileCoefficient 800 11 : ℤ) = Certificate.c 11 := by decide

theorem profile_coefficient_12 : (profileCoefficient 800 12 : ℤ) = Certificate.c 12 := by decide

theorem profile_coefficient_13 : (profileCoefficient 800 13 : ℤ) = Certificate.c 13 := by decide

theorem profile_coefficient_14 : (profileCoefficient 800 14 : ℤ) = Certificate.c 14 := by decide

theorem profile_coefficient_15 : (profileCoefficient 800 15 : ℤ) = Certificate.c 15 := by decide

theorem profile_coefficient_16 : (profileCoefficient 800 16 : ℤ) = Certificate.c 16 := by decide

theorem profile_coefficient_17 : (profileCoefficient 800 17 : ℤ) = Certificate.c 17 := by decide

theorem profile_coefficient_18 : (profileCoefficient 800 18 : ℤ) = Certificate.c 18 := by decide

theorem profile_coefficient_19 : (profileCoefficient 800 19 : ℤ) = Certificate.c 19 := by decide

theorem profile_coefficient_20 : (profileCoefficient 800 20 : ℤ) = Certificate.c 20 := by decide

theorem profile_coefficient_21 : (profileCoefficient 800 21 : ℤ) = Certificate.c 21 := by decide

theorem profile_coefficient_22 : (profileCoefficient 800 22 : ℤ) = Certificate.c 22 := by decide

theorem profile_coefficient_23 : (profileCoefficient 800 23 : ℤ) = Certificate.c 23 := by decide

theorem profile_coefficient_24 : (profileCoefficient 800 24 : ℤ) = Certificate.c 24 := by decide

theorem profile_coefficient_25 : (profileCoefficient 800 25 : ℤ) = Certificate.c 25 := by decide

theorem profile_coefficient_26 : (profileCoefficient 800 26 : ℤ) = Certificate.c 26 := by decide

theorem profile_coefficient_27 : (profileCoefficient 800 27 : ℤ) = Certificate.c 27 := by decide

theorem profile_coefficient_28 : (profileCoefficient 800 28 : ℤ) = Certificate.c 28 := by decide

theorem profile_coefficient_29 : (profileCoefficient 800 29 : ℤ) = Certificate.c 29 := by decide

theorem profile_coefficient_30 : (profileCoefficient 800 30 : ℤ) = Certificate.c 30 := by decide

theorem profile_coefficient_31 : (profileCoefficient 800 31 : ℤ) = Certificate.c 31 := by decide

theorem profile_coefficient_32 : (profileCoefficient 800 32 : ℤ) = Certificate.c 32 := by decide

theorem profile_coefficient_33 : (profileCoefficient 800 33 : ℤ) = Certificate.c 33 := by decide

theorem profile_coefficient_34 : (profileCoefficient 800 34 : ℤ) = Certificate.c 34 := by decide

theorem profile_coefficient_35 : (profileCoefficient 800 35 : ℤ) = Certificate.c 35 := by decide

theorem profile_coefficient_36 : (profileCoefficient 800 36 : ℤ) = Certificate.c 36 := by decide

theorem profile_coefficient_37 : (profileCoefficient 800 37 : ℤ) = Certificate.c 37 := by decide

theorem profile_coefficient_38 : (profileCoefficient 800 38 : ℤ) = Certificate.c 38 := by decide

/-- Check that every individual division in the finite enumeration is exact. -/
def profileDivisionsExact (r : ℕ) : Bool :=
  (List.range (r / 4 + 1)).all fun a₅ =>
  (List.range ((r - 4*a₅) / 3 + 1)).all fun a₄ =>
  (List.range ((r - 4*a₅ - 3*a₄) / 2 + 1)).all fun a₃ =>
    let a₂ := r - 4*a₅ - 3*a₄ - 2*a₃
    profileNumerator 800 a₂ a₃ a₄ a₅ % profileDenominator a₂ a₃ a₄ a₅ == 0

theorem all_profile_divisions_exact : ∀ r : Fin 39, profileDivisionsExact r.val = true := by
  decide

theorem profile_coefficient (r : ℕ) (hr : r < 39) :
    (profileCoefficient 800 r : ℤ) = Certificate.c r := by
  interval_cases r
  exact profile_coefficient_0
  exact profile_coefficient_1
  exact profile_coefficient_2
  exact profile_coefficient_3
  exact profile_coefficient_4
  exact profile_coefficient_5
  exact profile_coefficient_6
  exact profile_coefficient_7
  exact profile_coefficient_8
  exact profile_coefficient_9
  exact profile_coefficient_10
  exact profile_coefficient_11
  exact profile_coefficient_12
  exact profile_coefficient_13
  exact profile_coefficient_14
  exact profile_coefficient_15
  exact profile_coefficient_16
  exact profile_coefficient_17
  exact profile_coefficient_18
  exact profile_coefficient_19
  exact profile_coefficient_20
  exact profile_coefficient_21
  exact profile_coefficient_22
  exact profile_coefficient_23
  exact profile_coefficient_24
  exact profile_coefficient_25
  exact profile_coefficient_26
  exact profile_coefficient_27
  exact profile_coefficient_28
  exact profile_coefficient_29
  exact profile_coefficient_30
  exact profile_coefficient_31
  exact profile_coefficient_32
  exact profile_coefficient_33
  exact profile_coefficient_34
  exact profile_coefficient_35
  exact profile_coefficient_36
  exact profile_coefficient_37
  exact profile_coefficient_38

/-- Supplementary agreement with the profile enumeration. The final proof uses
`countingBell_certificate_bridge` directly and does not import this module. -/
theorem countingBell_profile_bridge (k : ℕ) (hk : k < 39) :
    (countingBell 800 5).coeff (800-k) = (profileCoefficient 800 k : ℂ) := by
  rw [countingBell_certificate_bridge k hk]
  exact_mod_cast (profile_coefficient k hk).symm

end RestrictedBell
