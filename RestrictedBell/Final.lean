import RestrictedBell.CountingBridge
import RestrictedBell.Counterexample

namespace RestrictedBell

/-- The counterexample polynomial is monic; its nonreal root is not vacuous. -/
theorem countingBell_800_5_monic : (countingBell 800 5).Monic := by
  apply Polynomial.monic_of_natDegree_le_of_coeff_eq_one 800
    (countingBell_degree_le 800 5)
  simpa [Certificate.c, Certificate.coefficients] using
    countingBell_certificate_bridge 0 (by decide)

/-- In particular, the counterexample polynomial is not the zero polynomial. -/
theorem countingBell_800_5_ne_zero : countingBell 800 5 ≠ 0 :=
  countingBell_800_5_monic.ne_zero

/-- The counting polynomial has degree exactly 800. -/
theorem countingBell_800_5_natDegree : (countingBell 800 5).natDegree = 800 := by
  have htop : (countingBell 800 5).coeff 800 = 1 := by
    simpa [Certificate.c, Certificate.coefficients] using
      countingBell_certificate_bridge 0 (by decide)
  exact Polynomial.natDegree_eq_of_le_of_coeff_ne_zero
    (countingBell_degree_le 800 5) (htop ▸ one_ne_zero)

/-- The actual restricted Bell polynomial B_{800,≤5} has a nonreal complex root. -/
theorem restrictedBell_800_5_nonreal :
    ∃ z : ℂ, (countingBell 800 5).IsRoot z ∧ z.im ≠ 0 :=
  counterexample_of_certificate_bridge countingBell_certificate_bridge

/-- Counterexample to the real-rootedness assertion of Conjecture 6.4. -/
theorem realRootedness_conjecture_false : ¬ RealRootednessConjecture :=
  conjecture_false_of_counterexample restrictedBell_800_5_nonreal

end RestrictedBell
