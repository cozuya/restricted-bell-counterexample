import RestrictedBell.Definition
import RestrictedBell.Obstruction

namespace RestrictedBell

/-- The real-rootedness part of Conjecture 6.4, in the original counting meaning. -/
def RealRootednessConjecture : Prop :=
  ∀ n m : ℕ, 1 ≤ m → m ≠ 3 → m ≠ 4 →
    ∀ z : ℂ, (countingBell n m).IsRoot z → z.im = 0

/-- Reduction from a monic quotient with the certified leading coefficients.
The hypotheses are supplied by `counterexample_of_certificate_bridge` below. -/
theorem counterexample_of_coefficient_bridge (q : Polynomial ℂ)
    (hfactor : countingBell 800 5 = Polynomial.X ^ 160 * q)
    (hm : q.Monic) (hd : q.natDegree = 640)
    (hc : ∀ k < 39, q.coeff (640 - k) = (Certificate.c k : ℂ)) :
    CounterexampleStatement := by
  obtain ⟨z, hz, him⟩ := nonreal_root_of_top_coefficients q hm hd hc
  refine ⟨z, ?_, him⟩
  rw [Polynomial.IsRoot, hfactor, Polynomial.eval_mul, hz.eq_zero, mul_zero]

/-- A nonreal root at the admissible pair `(800,5)` refutes the universal conjecture. -/
theorem conjecture_false_of_counterexample (h : CounterexampleStatement) :
    ¬ RealRootednessConjecture := by
  obtain ⟨z, hz, him⟩ := h
  intro hc
  exact him (hc 800 5 (by decide) (by decide) (by decide) z hz)

/-- The counting bridge implies the counterexample.
`CountingBridge.lean` proves this hypothesis; `Final.lean` applies it. -/
theorem counterexample_of_certificate_bridge
    (hbridge : ∀ k < 39, (countingBell 800 5).coeff (800-k) =
      (Certificate.c k : ℂ)) : CounterexampleStatement := by
  have htop : (countingBell 800 5).coeff 800 = 1 := by
    simpa [Certificate.c, Certificate.coefficients] using hbridge 0 (by decide)
  have hdeg := Polynomial.natDegree_eq_of_le_of_coeff_ne_zero
    (countingBell_degree_le 800 5) (htop ▸ one_ne_zero)
  have hmon := Polynomial.monic_of_natDegree_le_of_coeff_eq_one 800
    (countingBell_degree_le 800 5) htop
  obtain ⟨q, hq⟩ := countingBell_has_forced_factor
  have hqm : q.Monic := (Polynomial.monic_X.pow 160).of_mul_monic_left (hq ▸ hmon)
  have hqd : q.natDegree = 640 := by
    rw [hq, (Polynomial.monic_X.pow 160).natDegree_mul hqm] at hdeg
    simp only [Polynomial.natDegree_X_pow] at hdeg
    omega
  apply counterexample_of_coefficient_bridge q hq hqm hqd
  intro k hk
  have h := hbridge k hk
  rw [hq, show 800-k = (640-k)+160 by omega, Polynomial.coeff_X_pow_mul] at h
  exact h

end RestrictedBell
