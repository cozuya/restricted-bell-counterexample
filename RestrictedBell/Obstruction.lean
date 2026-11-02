import RestrictedBell.Newton
import RestrictedBell.Moments
import RestrictedBell.Certificate

namespace RestrictedBell
open scoped BigOperators

/-- The supplied moments cannot be power sums of any 640 real numbers. -/
theorem certificate_no_real_representation :
    ¬ ∃ r : Fin 640 → ℝ, ∀ k < 39,
      (Certificate.s k : ℝ) = ∑ l, r l ^ k := by
  apply no_real_moment_representation (d := 20)
    (fun k => (Certificate.s k : ℝ)) (fun i => (Certificate.u i.val : ℝ))
  have h : (∑ i : Fin 20, ∑ j : Fin 20,
      Certificate.u i.val * Certificate.s (i.val + j.val) * Certificate.u j.val) < 0 := by
    simpa only [Certificate.quadratic, Fin.sum_univ_eq_sum_range] using
      Certificate.quadratic_negative
  exact_mod_cast h

/-- Newton recurrence uniquely determines the certified moments from symmetric coefficients. -/
theorem moments_of_elementary (r : Fin 640 → ℂ)
    (hc : ∀ k < 39, elementary r k = (Certificate.c k : ℂ)) :
    ∀ k < 39, (Certificate.s k : ℂ) = ∑ l, r l ^ k := by
  intro k
  induction k using Nat.strong_induction_on with
  | h k ih =>
    intro hk
    by_cases hzero : k = 0
    · subst k
      norm_num [Certificate.s, Certificate.moments]
    have hpos : 0 < k := Nat.pos_of_ne_zero hzero
    have hn := Certificate.newton_antidiagonal ⟨k, hk⟩ hpos
    unfold Certificate.NewtonEquation at hn
    have hnC : (Certificate.s k : ℂ) = (-1 : ℂ) ^ (k+1) * k * Certificate.c k -
        ∑ a ∈ (Finset.antidiagonal k).filter (fun a => a.1 ∈ Set.Ioo 0 k),
          (-1 : ℂ) ^ a.1 * Certificate.c a.1 * Certificate.s a.2 := by
      exact_mod_cast hn
    rw [hnC, tuple_newton r k hpos, hc k hk]
    congr 1
    apply Finset.sum_congr rfl
    intro a ha
    obtain ⟨haSum, haLower, haUpper⟩ := Finset.mem_filter.mp ha
    have haEq := Finset.mem_antidiagonal.mp haSum
    rw [hc a.1 (by omega), ih a.2 (by omega) (by omega)]

/-- A finite root family with the certified moments contains a nonreal root.
The moment equalities are explicit hypotheses; no coefficient bridge is assumed globally. -/
theorem nonreal_root_of_certified_moments (p : Polynomial ℂ) (r : Fin 640 → ℂ)
    (hroot : ∀ l, p.IsRoot (r l))
    (hmom : ∀ k < 39, (Certificate.s k : ℂ) = ∑ l, (-r l) ^ k) :
    ∃ z : ℂ, p.IsRoot z ∧ z.im ≠ 0 := by
  by_contra h
  push_neg at h
  apply certificate_no_real_representation
  refine ⟨fun l => -(r l).re, ?_⟩
  intro k hk
  have hr (l : Fin 640) : r l = ((r l).re : ℂ) := by
    apply Complex.ext
    · simp
    · simpa using h (r l) (hroot l)
  have heq := hmom k hk
  have heq' : (Certificate.s k : ℂ) = ∑ l, ((-(r l).re : ℝ) : ℂ) ^ k := by
    rw [heq]
    apply Finset.sum_congr rfl
    intro l hl
    rw [hr l]
    simp
  exact_mod_cast heq' 

/-- Coefficients expressed as elementary symmetric functions suffice for the obstruction. -/
theorem nonreal_root_of_certified_elementary (p : Polynomial ℂ) (r : Fin 640 → ℂ)
    (hroot : ∀ l, p.IsRoot (r l))
    (hc : ∀ k < 39, elementary (fun l => -r l) k = (Certificate.c k : ℂ)) :
    ∃ z : ℂ, p.IsRoot z ∧ z.im ≠ 0 :=
  nonreal_root_of_certified_moments p r hroot (moments_of_elementary _ hc)

/-- Every monic complex polynomial of degree 640 with the certified top coefficients
has a nonreal root. This does not assert that a particular counting polynomial
has those coefficients. -/
theorem nonreal_root_of_top_coefficients (q : Polynomial ℂ)
    (hm : q.Monic) (hd : q.natDegree = 640)
    (hc : ∀ k < 39, q.coeff (640 - k) = (Certificate.c k : ℂ)) :
    ∃ z : ℂ, q.IsRoot z ∧ z.im ≠ 0 := by
  classical
  have hex : ∃ (n : ℕ) (r : Fin n → ℂ), Finset.univ.val.map r = q.roots := by
    refine ⟨q.roots.toList.length, q.roots.toList.get, ?_⟩
    rw [Fin.univ_val_map, List.ofFn_get, Multiset.coe_toList]
  obtain ⟨n, r, hr⟩ := hex
  have hn : n = 640 := by
    have hcard := congrArg Multiset.card hr
    have hdeg := (IsAlgClosed.splits q).natDegree_eq_card_roots
    simpa [← hdeg, hd] using hcard
  subst n
  apply nonreal_root_of_certified_elementary q r
  · intro l
    apply (Polynomial.mem_roots hm.ne_zero).mp
    rw [← hr]
    exact Multiset.mem_map.mpr ⟨l, by simp, rfl⟩
  · intro k hk
    have he : elementary (fun l => -r l) k = (q.roots.map Neg.neg).esymm k := by
      unfold elementary
      rw [← hr, Multiset.map_map]
      rfl
    rw [he, Multiset.esymm_neg]
    have hv := Polynomial.coeff_eq_esymm_roots_of_splits
      (IsAlgClosed.splits q) (k := 640-k) (by omega)
    rw [hd, Nat.sub_sub_self (by omega), hm.leadingCoeff, one_mul] at hv
    rw [← hv]
    exact hc k hk

end RestrictedBell
