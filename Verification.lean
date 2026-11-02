import RestrictedBell.Final

namespace Verification

/-- The counterexample with the finite-partition counting definition written out. -/
theorem counting_definition_nonreal :
    ∃ z : ℂ,
      (∑ p : {p : Finpartition (Finset.univ : Finset (Fin 800)) //
          ∀ b ∈ p.parts, b.card ≤ 5},
        (Polynomial.X : Polynomial ℂ) ^ p.val.parts.card).IsRoot z ∧ z.im ≠ 0 := by
  exact RestrictedBell.restrictedBell_800_5_nonreal

/-- The real-rootedness assertion with its quantifiers and admissible caps explicit. -/
theorem conjecture_false :
    ¬ (∀ n m : ℕ, 1 ≤ m → m ≠ 3 → m ≠ 4 →
      ∀ z : ℂ, (RestrictedBell.countingBell n m).IsRoot z → z.im = 0) :=
  RestrictedBell.realRootedness_conjecture_false

end Verification

-- Small counting checks through the proved combinatorial bridge:
-- three pairings, or those three pairings plus four singleton/triple splits.
example : (RestrictedBell.countingBell 4 2).coeff 2 = 3 := by
  rw [RestrictedBell.countingBell_coeff_eq_stirling]
  norm_num [RestrictedBell.stirling, Finset.sum_range_succ]

example : (RestrictedBell.countingBell 4 3).coeff 2 = 7 := by
  rw [RestrictedBell.countingBell_coeff_eq_stirling]
  norm_num [RestrictedBell.stirling, Finset.sum_range_succ]

#check Verification.counting_definition_nonreal
#check Verification.conjecture_false
#check RestrictedBell.restrictedBell_800_5_nonreal
#check RestrictedBell.realRootedness_conjecture_false
#check RestrictedBell.countingBell_coeff_eq_stirling
#check RestrictedBell.countingBell_eq_recurrenceBell
#check RestrictedBell.countingBell_certificate_bridge
#check RestrictedBell.countingBell_800_5_monic
#check RestrictedBell.countingBell_800_5_ne_zero
#check RestrictedBell.countingBell_800_5_natDegree

#print axioms Verification.counting_definition_nonreal
#print axioms Verification.conjecture_false
#print axioms RestrictedBell.restrictedBell_800_5_nonreal
#print axioms RestrictedBell.realRootedness_conjecture_false
#print axioms RestrictedBell.countingBell_coeff_eq_stirling
#print axioms RestrictedBell.countingBell_eq_recurrenceBell
#print axioms RestrictedBell.ComputedRows.row800_correct
#print axioms RestrictedBell.countingBell_certificate_bridge
#print axioms RestrictedBell.countingBell_800_5_monic
#print axioms RestrictedBell.countingBell_800_5_ne_zero
#print axioms RestrictedBell.countingBell_800_5_natDegree
#print axioms RestrictedBell.Certificate.quadratic_exact
#print axioms RestrictedBell.Certificate.newton_antidiagonal
