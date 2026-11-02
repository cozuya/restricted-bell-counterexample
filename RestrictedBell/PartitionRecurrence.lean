import RestrictedBell.Profiles

namespace RestrictedBell
open scoped BigOperators
namespace PartitionRecurrence
set_option maxHeartbeats 1500000
variable {α : Type*} [DecidableEq α] {s b : Finset α}

/-- Removing a whole block leaves precisely the other blocks. -/
theorem avoid_parts (p : Finpartition s) (hb : b ∈ p.parts) :
    (p.avoid b).parts = p.parts.erase b := by
  ext c
  rw [Finpartition.mem_avoid, Finset.mem_erase]
  constructor
  · rintro ⟨d, hd, hn, he⟩
    have hne : d ≠ b := by rintro rfl; exact hn le_rfl
    have hdis := p.disjoint hd hb hne
    have hdif : d \ b = d := Finset.sdiff_eq_self_of_disjoint hdis
    rw [hdif] at he
    subst c
    exact ⟨hne, hd⟩
  · rintro ⟨hne, hc⟩
    have hdis := p.disjoint hc hb hne
    refine ⟨c, hc, ?_, Finset.sdiff_eq_self_of_disjoint hdis⟩
    intro hle
    exact p.ne_empty hc (hdis.eq_bot_of_le hle)

/-- Attach a chosen block to a partition of its complement. -/
def attach (hb : b ⊆ s) (hne : b.Nonempty) (q : Finpartition (s \ b)) :
    Finpartition s :=
  q.extend hne.ne_empty Finset.sdiff_disjoint (Finset.sdiff_union_of_subset hb)

@[simp] theorem attach_parts (hb : b ⊆ s) (hne : b.Nonempty)
    (q : Finpartition (s \ b)) : (attach hb hne q).parts = insert b q.parts := rfl

 theorem block_notMem_complement (hne : b.Nonempty) (q : Finpartition (s \ b)) :
    b ∉ q.parts := by
  intro h
  obtain ⟨a, ha⟩ := hne
  exact (Finset.mem_sdiff.mp (q.subset h ha)).2 ha

 theorem attach_avoid (p : Finpartition s) (hb : b ∈ p.parts) :
    attach (p.subset hb) (p.nonempty_of_mem_parts hb) (p.avoid b) = p := by
  apply Finpartition.ext
  rw [attach_parts, avoid_parts p hb, Finset.insert_erase hb]

 theorem avoid_attach (hb : b ⊆ s) (hne : b.Nonempty)
    (q : Finpartition (s \ b)) : (attach hb hne q).avoid b = q := by
  apply Finpartition.ext
  rw [avoid_parts _ (by simp), attach_parts,
    Finset.erase_insert (block_notMem_complement hne q)]

/-- Eligible blocks containing the distinguished label. -/
def Block (s : Finset α) (a : α) := {b : Finset α // b ⊆ s ∧ a ∈ b}

theorem partition_heq {t : Finset α} (p : Finpartition s) (q : Finpartition t)
    (hst : s = t) (hp : p.parts = q.parts) : HEq p q := by
  subst t
  exact heq_of_eq (Finpartition.ext hp)

/-- A partition is determined by the block containing one fixed label and
an arbitrary partition of the remaining labels. -/
noncomputable def splitEquiv (s : Finset α) (a : α) (ha : a ∈ s) :
    Finpartition s ≃ Σ b : Block s a, Finpartition (s \ b.val) where
  toFun p := ⟨⟨p.part a, p.part_subset a, p.mem_part ha⟩, p.avoid (p.part a)⟩
  invFun x := attach x.1.property.1 ⟨a, x.1.property.2⟩ x.2
  left_inv p := attach_avoid p (p.part_mem.mpr ha)
  right_inv x := by
    rcases x with ⟨⟨b, hb, hab⟩, q⟩
    have he : (attach hb ⟨a, hab⟩ q).part a = b :=
      Finpartition.part_eq_of_mem _ (by simp) hab
    apply Sigma.ext
    · exact Subtype.ext he
    · dsimp
      apply partition_heq _ _ (congrArg (fun c => s \ c) he)
      rw [he]
      exact congrArg Finpartition.parts (avoid_attach hb ⟨a, hab⟩ q)

noncomputable instance [Fintype α] (s : Finset α) (a : α) : Fintype (Block s a) := by
  classical
  unfold Block
  infer_instance

/-- Number of restricted partitions of a finite labeled set with exactly `k` blocks. -/
noncomputable def count [Fintype α] (s : Finset α) (m k : ℕ) : ℕ := by
  classical
  exact ∑ p : Finpartition s,
    if p.parts.card = k ∧ (∀ b ∈ p.parts, b.card ≤ m) then 1 else 0

theorem attach_card (hb : b ⊆ s) (hne : b.Nonempty)
    (q : Finpartition (s \ b)) : (attach hb hne q).parts.card = q.parts.card + 1 := by
  rw [attach_parts, Finset.card_insert_of_notMem (block_notMem_complement hne q)]

theorem attach_capped (hb : b ⊆ s) (hne : b.Nonempty)
    (q : Finpartition (s \ b)) (m : ℕ) :
    (∀ c ∈ (attach hb hne q).parts, c.card ≤ m) ↔
      b.card ≤ m ∧ ∀ c ∈ q.parts, c.card ≤ m := by
  simp [attach_parts]

/-- Symbolic recurrence by the block containing a distinguished label.
No enumeration of partitions is performed by this proof. -/
theorem count_succ [Fintype α] (s : Finset α) (a : α) (ha : a ∈ s) (m k : ℕ) :
    count s m (k+1) = ∑ b : Block s a,
      if b.val.card ≤ m then count (s \ b.val) m k else 0 := by
  classical
  unfold count
  rw [← (splitEquiv s a ha).symm.sum_comp]
  rw [Fintype.sum_sigma]
  apply Finset.sum_congr rfl
  intro b hb
  simp only [splitEquiv, Equiv.coe_fn_symm_mk, attach_card,
    Nat.add_right_cancel_iff, attach_capped]
  by_cases h : b.val.card ≤ m
  · simp [h, -Finset.sum_boole]
  · simp [h, -Finset.sum_boole]

/-- Delete the distinguished label from its chosen block. -/
def blockEquivPowerset (s : Finset α) (a : α) (ha : a ∈ s) :
    Block s a ≃ ↥((s.erase a).powerset) where
  toFun b := ⟨b.val.erase a, Finset.mem_powerset.mpr (Finset.erase_subset_erase a b.property.1)⟩
  invFun t := ⟨insert a t.val, Finset.insert_subset ha
      ((Finset.mem_powerset.mp t.property).trans (Finset.erase_subset a s)), by simp⟩
  left_inv b := Subtype.ext (Finset.insert_erase b.property.2)
  right_inv t := Subtype.ext (Finset.erase_insert
    (fun h => (Finset.mem_erase.mp (Finset.mem_powerset.mp t.property h)).1 rfl))

theorem sum_blocks_card [Fintype α] (s : Finset α) (a : α) (ha : a ∈ s)
    (f : ℕ → ℕ) :
    (∑ b : Block s a, f b.val.card) =
      ∑ j ∈ Finset.range s.card, (s.card-1).choose j * f (j+1) := by
  classical
  rw [← (blockEquivPowerset s a ha).symm.sum_comp]
  have hcard (t : ↥((s.erase a).powerset)) :
      ((blockEquivPowerset s a ha).symm t).val.card = t.val.card+1 := by
    apply Finset.card_insert_of_notMem
    intro h
    exact (Finset.mem_erase.mp (Finset.mem_powerset.mp t.property h)).1 rfl
  simp_rw [hcard]
  rw [Finset.sum_coe_sort (s.erase a).powerset (fun t => f (t.card+1)), Finset.sum_powerset]
  simp_rw [Finset.sum_powersetCard _ _ (fun j => f (j+1))]
  rw [Finset.card_erase_of_mem ha, Nat.sub_add_cancel (Finset.card_pos.mpr ⟨a, ha⟩)]
  rfl

theorem count_empty [Fintype α] (m k : ℕ) : count (∅ : Finset α) m k = if k = 0 then 1 else 0 := by
  classical
  have hp (p : Finpartition (∅ : Finset α)) : p.parts = ∅ :=
    Finpartition.parts_eq_empty_iff.mpr rfl
  letI : Unique (Finpartition (∅ : Finset α)) :=
    ⟨⟨Finpartition.empty _⟩, fun p => Finpartition.ext (hp p)⟩
  simp [count, hp, eq_comm]

theorem count_zero [Fintype α] (s : Finset α) (hs : s.Nonempty) (m : ℕ) : count s m 0 = 0 := by
  classical
  have hp (p : Finpartition s) : p.parts.card ≠ 0 := by
    intro h
    exact hs.ne_empty (Finpartition.parts_eq_empty_iff.mp (Finset.card_eq_zero.mp h))
  simp [count, hp]

/-- Version of the defining recurrence with a cap predicate in the summand. -/
theorem stirling_succ (m n k : ℕ) :
    stirling m (n+1) (k+1) = ∑ j ∈ Finset.range (n+1),
      if j+1 ≤ m then n.choose j * stirling m (n-j) k else 0 := by
  rw [stirling, ← Finset.sum_filter]
  congr 1
  ext j
  simp only [Finset.mem_range, Finset.mem_filter]
  omega

/-- The actual partition count satisfies the restricted Stirling recurrence. -/
theorem count_eq_stirling [Fintype α] (s : Finset α) (m k : ℕ) :
    count s m k = stirling m s.card k := by
  classical
  induction hn : s.card using Nat.strong_induction_on generalizing s k with
  | h n ih =>
    cases n with
    | zero =>
      have hs := Finset.card_eq_zero.mp hn
      subst s
      simp [count_empty, stirling]
    | succ n =>
      obtain ⟨a, ha⟩ := Finset.card_pos.mp (show 0 < s.card by omega)
      cases k with
      | zero =>
        rw [count_zero s ⟨a, ha⟩ m]
        simp [stirling]
      | succ k =>
        rw [count_succ s a ha]
        have hrem (b : Block s a) : count (s \ b.val) m k =
            stirling m (s.card - b.val.card) k := by
          have hpos := Finset.card_pos.mpr (show b.val.Nonempty from ⟨a, b.property.2⟩)
          have hcard := Finset.card_sdiff_of_subset b.property.1
          rw [ih (s \ b.val).card (by omega) (s \ b.val) k rfl, hcard]
        simp_rw [hrem]
        rw [sum_blocks_card s a ha (fun j => if j ≤ m then stirling m (s.card-j) k else 0)]
        rw [hn, stirling_succ]
        apply Finset.sum_congr rfl
        intro j hj
        simp only [Nat.add_sub_cancel, Nat.add_sub_add_right, mul_ite, mul_zero]

end PartitionRecurrence
/-- The recurrence-defined numbers count the actual bounded set partitions. -/
theorem countingBell_coeff_eq_stirling (n m k : ℕ) :
    (countingBell n m).coeff k = (stirling m n k : ℂ) := by
  classical
  rw [countingBell_coeff_eq_card]
  let e := (Equiv.subtypeSubtypeEquivSubtypeInter
    (fun p : Finpartition (Finset.univ : Finset (Fin n)) => ∀ b ∈ p.parts, b.card ≤ m)
    (fun p => p.parts.card = k)).trans
    ((Equiv.refl _).subtypeEquiv
      (q := fun p => p.parts.card = k ∧ ∀ b ∈ p.parts, b.card ≤ m)
      (fun p => and_comm))
  have hcard : Fintype.card {p : BoundedPartition n m // p.val.parts.card = k} =
      PartitionRecurrence.count (Finset.univ : Finset (Fin n)) m k := by
    calc
      _ = Fintype.card {p : Finpartition (Finset.univ : Finset (Fin n)) //
          p.parts.card = k ∧ ∀ b ∈ p.parts, b.card ≤ m} := Fintype.card_congr e
      _ = _ := by
        rw [Fintype.card_subtype, Finset.card_filter]
        rfl
  rw [hcard, PartitionRecurrence.count_eq_stirling]
  simp

theorem countingBell_eq_recurrenceBell (n m : ℕ) :
    countingBell n m = recurrenceBell n m := by
  classical
  unfold recurrenceBell
  conv_lhs => rw [Polynomial.as_sum_range' (countingBell n m) (n+1)
    (Nat.lt_succ_of_le (countingBell_degree_le n m))]
  apply Finset.sum_congr rfl
  intro k hk
  rw [countingBell_coeff_eq_stirling]

end RestrictedBell
