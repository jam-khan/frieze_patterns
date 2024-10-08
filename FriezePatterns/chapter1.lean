import Mathlib.Algebra.Ring.Basic
import Mathlib.Tactic

---- Field-valued patterns ----
class pattern_n (F : Type*) [Field F] (f : ℕ × ℕ → F) (n : ℕ) : Prop where
  topBordZeros : ∀ m, f (0,m) = 0
  topBordOnes : ∀ m, f (1,m) =1
  botBordOnes_n : ∀ m, f (n, m) = 1
  botBordZeros_n : ∀ i, ∀ m,  i ≥ n+1 → (f (i,m) = 0)
  diamond : ∀ i, ∀ m,  i ≤ n-1 → f (i+1,m) * f (i+1,m+1)-1 = f (i+2,m)*f (i,m+1)

class nzPattern_n (F : Type*) [Field F] (f : ℕ × ℕ → F) (n : ℕ) extends pattern_n F f n where
  non_zero : ∀ i, ∀ m, 1 ≤ i ∧ i ≤ n → f (i,m) ≠ 0


lemma pattern_nContinuant1 (F : Type*) [Field F] (f : ℕ×ℕ → F) (n: ℕ) [nzPattern_n F f n] : ∀ i, i ≤ n-1 → ∀m, f (i+2,m) = f (2,m+i)*f (i+1,m) - f (i,m) := by
  intro i
  induction i with
  | zero =>
  simp
  intro m
  have h₀ : f (0, m) = 0 := by exact pattern_n.topBordZeros n m
  have h₁ : f (1, m) = 1 := by exact pattern_n.topBordOnes n m
  rw [h₀, h₁]
  simp
  | succ k ih =>
  intro h m
  have h' : 1 ≤ k+1 ∧ k+1 ≤ n := by omega
  have hh' : k ≤ n-1 := by omega
  have ih₁ : f (k + 2, m + 1) = f (2, m + 1 + k) * f (k + 1, m + 1) - f (k, m + 1) := by exact ih hh' (m+1)
  have h₂ : f (k + 1, m + 1) ≠ 0 := by exact nzPattern_n.non_zero (k+1) (m+1) h'
  have h₃ : f (k + 3, m) * f (k + 1, m + 1) = (f (k + 2, m) * f (2, m + k + 1) - f (k + 1, m)) * f (k + 1, m + 1) :=
    calc f (k + 3, m) * f (k + 1, m + 1) = f (k + (2+1), m) * f (k + 1, m + 1) := by rw [two_add_one_eq_three]
      _= f ((k + 1) + 2, m) * f (k + 1, m + 1) := by rw [Nat.add_comm 1 2, ← Nat.add_assoc]
      _= f ((k + 1)+1, m) * f ((k + 1)+1, m + 1) - 1 := by rw [← pattern_n.diamond (k+1) m h]
      _= f ((k + 1)+1, m) * f (k + 2, m + 1) - 1 := by simp
      _= f (k + 2, m) * (f (2, m + 1 + k) * f (k + 1, m + 1) - f (k, m + 1)) - 1 := by rw [ih₁]
      _= f (k + 2, m) * (f (2, m + k + 1) * f (k + 1, m + 1) - f (k, m + 1)) - 1 := by rw [add_right_comm]
      _= f (k + 2, m) * (f (2, m + k + 1) * f (k + 1, m + 1)) - f (k + 2, m) * f (k, m + 1) - 1 := by rw [mul_sub_left_distrib]
      _= f (k + 2, m) * f (2, m + k + 1) * f (k + 1, m + 1) - (f (k + 2, m) * f (k, m + 1) + 1) := by rw [mul_assoc, sub_sub]
      _= f (k + 2, m) * f (2, m + k + 1) * f (k + 1, m + 1) - (f (k + 1, m) * f (k + 1, m + 1) - 1 + 1) := by rw [← pattern_n.diamond k m hh']
      _= f (k + 2, m) * f (2, m + k + 1) * f (k + 1, m + 1) - f (k + 1, m) * f (k + 1, m + 1) := by rw [add_comm_sub, sub_self, add_zero]
      _= (f (k + 2, m) * f (2, m + k + 1) - f (k + 1, m)) * f (k + 1, m + 1) := by rw [← sub_mul]
  rw [add_assoc, add_assoc, one_add_one_eq_two]
  nth_rw 2 [add_comm]
  rw [two_add_one_eq_three]
  rw [← add_assoc, mul_comm]
  rw [← mul_inv_cancel_right₀ h₂ (f (k + 3, m))]
  rw [mul_inv_eq_iff_eq_mul₀]
  exact h₃
  exact h₂

-- The second continuant lemma is proved like the first
lemma pattern_nContinuant2 (F : Type*) [Field F] (f : ℕ×ℕ → F) (n: ℕ) [nzPattern_n F f n] : ∀ i, i ≤ n-1 → ∀m, f (i,m+2) = f (n-1,m+2)*f (i+1,m+1) - f (i+2,m) := by
by_cases one_leq_n : 1 ≤ n
suffices pattern_nContinuant2flipped : ∀ i, i ≤ n-1 → ∀m, f (n-i-1,m+2) = f (n-1,m+2)*f (n-i,m+1) - f (n-i+1,m)
-- Flip i to n-i so we can induct forwards
·intro i h m
 have key : n - i - 1 ≤ n - 1 := by omega
 have i_plus_one_leq_n : i + 1 ≤ n := by omega
 have key2 : n - (n - i - 1) - 1 = i := by omega
 have key3 : n - (n - i - 1) = i + 1 := by omega

 calc f (i, m + 2) = f (n - (n - i - 1) - 1, m + 2) := by rw[key2]
          _= f (n-1,m+2)*f (n-(n - i - 1),m+1) - f (n-(n - i - 1) + 1,m) := by rw[pattern_nContinuant2flipped (n - i - 1) key]
          _= f (n-1,m+2)*f (i+1,m+1) - f (i+2,m) := by rw[key3]

-- Have proved sufficiency of the flipped version

·intro i h
 induction i with
 | zero =>
 intro m
 simp
 have hₙ : f (n,m+1) = 1 ∧ f (n+1,m) = 0 := by exact ⟨pattern_n.botBordOnes_n (m+1), pattern_n.botBordZeros_n (n+1) m (by linarith)⟩
 rw[hₙ.2,hₙ.1,sub_zero,mul_one]
 | succ k ih =>
 intro m

 have a₀₁ : 1 ≤ n - k - 1 := by omega
 have a₀₁' : 2 ≤ n - k := by omega
 have a₁ : n - (k + 1) - 1 + 2 = n - k := by omega
 have a₂ : n - (k + 1) - 1 + 1 = n - k - 1 := by omega
 have a₃ : 1 ≤ n - (k + 1) - 1 + 2 ∧ n - (k + 1) - 1 + 2 ≤ n := by omega
 have a₅ : k ≤ n-1 := by omega
 have a₇ : n - (k + 1) - 1 ≤ n - 1 := by omega
 have a₁₁ : n - (k + 1) - 1 + 1 = n - (k + 1) := Nat.sub_add_cancel (a₀₁)
 have a₁₂ : n - (k + 1) - 1 + 2 = n - (k + 1) + 1 := by omega
 have a₉ : n - (k + 1) - 1 + 1 + 2 = n - k + 1 := by omega
 have a₁₀ : n - (k + 1) - 1 + 1 ≤ n - 1 := by omega

 have h₂ : f (n - (k + 1) - 1 + 2, m + 1) ≠ 0 := by exact nzPattern_n.non_zero (n - (k + 1) - 1 + 2) (m + 1) a₃

 calc f (n - (k + 1) - 1, m + 2) =  f (n - (k + 1) - 1, m+2) * f (n - (k + 1) - 1 + 2, m + 1) * (f (n - (k + 1) - 1 + 2, m + 1))⁻¹ := by rw [mul_inv_cancel_right₀ h₂ (f (n - (k + 1) - 1, m+2))]
          _= f (n - (k + 1) - 1 + 2, m + 1) * f (n - (k + 1) - 1, (m + 1) + 1) * (f (n - (k + 1) - 1 + 2, m + 1))⁻¹ := by ring
          _= ( f (n - (k + 1) - 1 + 1, m + 1) * f (n - (k + 1) - 1 + 1, (m + 1) + 1) - 1) * (f (n - (k + 1) - 1 + 2, m + 1))⁻¹ := by rw[pattern_n.diamond (n - (k + 1) - 1) (m+1) a₇]
          _= ( f (n - (k + 1) - 1 + 1, m + 1) * f (n - (k + 1) - 1 + 1, m + 2) - 1) * (f (n - (k + 1) - 1 + 2, m + 1))⁻¹ := by simp
          _= ( f (n - (k + 1) - 1 + 1, m + 1) * f (n - k - 1, m + 2) - 1) * (f (n - (k + 1) - 1 + 2, m + 1))⁻¹ := by rw[a₂]
          _= ( f (n - (k + 1) - 1 + 1, m + 1) * (f (n - 1, m + 2) * f (n - k, m + 1) - f (n - k + 1, m)) - 1) * (f (n - (k + 1) - 1 + 2, m + 1))⁻¹ := by rw[← ih a₅]
          _= (f (n - 1, m + 2) * f (n - (k + 1) - 1 + 1, m + 1) * f (n - k, m + 1) - f (n - k + 1, m) * f (n - (k + 1) - 1 + 1, m + 1) - 1) * (f (n - (k + 1) - 1 + 2 , m + 1))⁻¹ := by ring
          _= (f (n - 1, m + 2) * f (n - (k + 1) - 1 + 1, m + 1) * f (n - k, m + 1) - f (n - (k + 1) - 1 + 1 + 2, m) * f (n - (k + 1) - 1 + 1, m + 1) - 1) * (f (n - (k + 1) - 1 + 2 , m + 1))⁻¹ := by rw[a₉]
          _= (f (n - 1, m + 2) * f (n - (k + 1) - 1 + 1, m + 1) * f (n - k, m + 1) - (f (n - (k + 1) - 1 + 1+1,m) * f (n - (k + 1) - 1 + 1 + 1, m + 1) - 1) - 1) * (f (n - (k + 1) - 1 + 2 , m + 1))⁻¹ := by rw[pattern_n.diamond (n - (k + 1) - 1 + 1) (m) a₁₀]
          _= f (n - 1, m + 2) * f (n - (k + 1) - 1 + 1, m + 1) * f (n - k, m + 1) * (f (n - (k + 1) - 1 + 2, m + 1))⁻¹ - f (n - (k + 1) - 1 + 2,m) * f (n - (k + 1) - 1 + 2 , m + 1) * (f (n - (k + 1) - 1 + 2 , m + 1))⁻¹  := by ring
          _= f (n - 1, m + 2) * f (n - (k + 1), m + 1) * f (n - (k + 1) - 1 + 2, m + 1) * (f (n - (k + 1) - 1 + 2, m + 1))⁻¹ - f (n - (k + 1) - 1 + 2, m) * f (n - (k + 1) - 1 + 2 , m + 1) * (f (n - (k + 1) - 1 + 2 , m + 1))⁻¹  := by rw[a₁₁, a₁]
          _= f (n - 1, m + 2) * f (n - (k + 1), m + 1) - f (n - (k + 1) - 1 + 2, m) := by rw[mul_inv_cancel_right₀ h₂ (f (n - 1, m + 2) * f (n - (k + 1), m + 1)), mul_inv_cancel_right₀ h₂ (f (n - (k + 1) - 1 + 2, m))]
          _= f (n - 1, m + 2) * f (n - (k + 1), m + 1) - f (n - (k + 1) + 1, m) := by rw[a₁₂]
--Have proved it in the case 1 ≤ n

have n_eq_zero : n = 0 := by linarith
intro i h m
have i_leq_zero : i ≤ 0 := by omega
have i_eq_zero : i = 0 := by linarith

rw[i_eq_zero, n_eq_zero]
simp
rw[@pattern_n.topBordZeros F _ f n _ (m+2), @pattern_n.botBordZeros_n F _ f n _ (2) m (by linarith),zero_mul, sub_zero]


theorem trsltInv (F : Type*) [Field F] (f : ℕ×ℕ → F) (n: ℕ) [nzPattern_n F f n] : ∀ i, i ≤ n+1 → ∀m, f (i,m) = f (i,m+n+1) := by
  -- it suffices to prove glide symmetry
  suffices glideSymm : ∀ i, i ≤ n+1 → ∀ m, f (n+1-i, m+i) = f (i,m)
  · intros i ileq m
    have key := glideSymm i ileq m
    have key2 := glideSymm (n+1-i) (Nat.sub_le (n+1) i) (m+i)
    simp [Nat.sub_sub_eq_min, ileq, add_assoc] at key2
    rw [←key, ←key2, add_assoc]

  -- proof of glide symmetry
  · intros i ileq
    induction' i using Nat.strong_induction_on with i ih -- strong induction on i
    match i with
    | 0 => -- P₀
      simp
      intro m
      rw [@pattern_n.botBordZeros_n F _ f n _ (n+1) m (by linarith), @pattern_n.topBordZeros F _ f n _ m]
    | 1 => -- P₁
      simp at *
      intro m
      rw [@pattern_n.botBordOnes_n F _ f n _ (m+1), @pattern_n.topBordOnes F _ f n _ m]
    | i+2 =>
      simp at *
      intro m
      rw [Nat.sub_add_eq, ← add_assoc m i 2]
      have h₁ : i ≤ n-1 := by omega
      have h₂ : f (2,m+i) = f (n-1,m+i+2) := by -- we first prove P₂
        have key := pattern_nContinuant2 F f n 0 (by linarith) (m+i)
        simp at key
        rw [@pattern_n.topBordZeros F _ f n _ (m+i+2), @pattern_n.topBordOnes F _ f n _ (m+i+1)] at key
        simp at key
        exact (sub_eq_zero.mp key.symm).symm
      have h₃ : f (i+1,m) = f (n-i,m+i+1) := by
        have := ih (i+1) (by linarith) (by linarith)
        simp at this
        rw [← this, add_assoc]
      have h₄ : f (i,m) = f (n+1-i,m+i) := by
        have := ih i (by linarith) (by linarith)
        simp at this
        rw [← this]
      have h₅ : f (n-i-1,m+i+2) = f (n-1,m+i+2) * f (n-i,m+i+1) - f (n+1-i,m+i) := by
        have key := pattern_nContinuant2 F f n (n-i-1) (by omega) (m+i)
        rw [key, Nat.sub_sub n i 1, ← Nat.sub_add_comm ileq, ← Nat.sub_add_comm ileq]
        simp
      symm
      calc
        f (i+2,m) = f (2,m+i) * f (i+1,m) - f (i,m) := by rw [pattern_nContinuant1 F f n i h₁ m]
                _ = f (n-1,m+i+2) * f (n-i,m+i+1) - f (n+1-i,m+i) := by rw [h₂, h₃, h₄]
                _ = f (n-i-1,m+i+2) := by rw [h₅]


lemma imageFinite (F : Type*) [Field F] (f : ℕ×ℕ → F) (n: ℕ) [nzPattern_n F f n] : Finite (Set.range f) := by
-- We use i ≤ n instead of 1 ≤ i ≤ n to simplify the induction. Lean also automatically infers that {i : ℕ | i ≤ n} is finite.
  have key : Set.range f = f '' ({i : ℕ | i ≤ n} ×ˢ {m : ℕ | m ≤ n}) := by
    apply Set.ext_iff.mpr
    -- the hard part: L.H.S. is a subset of R.H.S.
    intro x ; apply Iff.intro
    intro hx ; unfold Set.range at hx
    rcases hx with ⟨⟨i, m⟩, hx⟩
    by_cases hi : i ≤ n
    · induction' m using Nat.strong_induction_on with m ih
      by_cases hm : m ≤ n
      · exact ⟨⟨i, m⟩, ⟨⟨hi, hm⟩, hx⟩⟩ -- we can just use (i,m) if m ≤ n
      · simp at hm
        specialize ih (m-(n+1)) (@Nat.sub_lt m (n+1) (by linarith) (by linarith))
        have key := trsltInv F f n i (by linarith) (m - (n + 1))
        have : m - (n+1) + n + 1 = m - (n+1) + (n+1) := by linarith
        simp [this, Nat.sub_add_cancel hm, hx] at key
        exact ih key
    · use ⟨0, 0⟩ ; apply And.intro (by simp) -- if i > n, then f(i,n) = 0, so we can use (0,0)
      rw [@pattern_n.topBordZeros F _ f n _ 0, ← hx, @pattern_n.botBordZeros_n F _ f n _ i m (by linarith)]
    -- now the trivial part
    intro hx ; rcases hx with ⟨y, hy⟩ ; exact ⟨y, hy.2⟩
  rw [key]
  have : Finite ({i : ℕ | i ≤ n} ×ˢ {m : ℕ | m ≤ n}) := by apply Finite.Set.finite_prod
  exact Finite.Set.finite_image ({i : ℕ | i ≤ n} ×ˢ {m : ℕ | m ≤ n}) f

/- We don't need this lemma anymore -/
lemma testEqualPattern (F : Type*) [Field F] (f g : ℕ×ℕ → F) (n: ℕ) (hf : nzPattern_n F f n) (hg : nzPattern_n F g n) (h : ∀ i, i ≤ n → f (i,0) = g (i,0)) : f = g := sorry
/- Antoine: I have put the proof in comments for the moment to avoids bugs during compilation on GitHub pages
lemma testEqualPattern (F : Type*) [Field F] (f g : ℕ×ℕ → F) (n: ℕ) (hf : nzPattern_n F f n) (hg : nzPattern_n F g n) (h : ∀ i, i ≤ n → f (i,0) = g (i,0)) : f = g := by
  funext ⟨i, m⟩

  induction m with
  | zero =>
    by_cases ileqn : i ≤ n
    exact h i ileqn
    have this := hf.botBordZeros_n i 0 (by linarith)
    --have that : g (i,0)=0 := by exact pattern_n.botBordZeros_n 0 i
    have that := hg.botBordZeros_n i 0 (by linarith)
    rw[this,that]

  | succ k ih =>
  -- assume f (i, k) = g (i, k) for i, want to prove f (i, k + 1) = g (i, k + 1) for all i

  induction i with
  --induction' i using Nat.twoStepInduction with i' IH1 IH2
  --. calc f (0,k+1) = 0 := by rw [hf.topBordZeros (k+1)]
  --    _ = g (0,k+1) := by rw [hg.topBordZeros (k+1)]

  --. calc f (1,k+1) = 1 := by rw [hf.topBordOnes (k+1)]
  --    _ = g (1,k+1) := by rw [hg.topBordOnes (k+1)]
  --.

    | zero =>
    have this := hf.topBordZeros (k+1)
    have that := hg.topBordZeros (k+1)
    rw[this,that]
    ----proved f (0, k + 1) = g (0, k + 1)

    | succ i' ih' =>
    --assume that f (i', k) = g (i', k) implies f (i', k+1) = g (i', k+1).
    --want to prove f (i', k + 1) = g (i', k + 1)

    by_cases i_plus_one_leq_n : i' + 1 ≤ n
    have one_leq_i_plus_1 : 1 ≤ i' + 1 :=
      calc 1 ≤ 0 + 1 := by simp
            _≤ i'+ 1 := Nat.succ_le_succ (Nat.zero_le i')

    have nzf : f (i' + 1, k) ≠ 0 := by apply hf.non_zero (i'+1) k one_leq_i_plus_1 i_plus_one_leq_n
    have nzg : g (i' + 1, k) ≠ 0 := by apply hg.non_zero (i'+1) k one_leq_i_plus_1 i_plus_one_leq_n


    have i_leq_n_sub_one : i' ≤ n - 1 :=
      calc i'≤ (i'+1).pred := by simp
            _≤ (n).pred :=  Nat.pred_le_pred i_plus_one_leq_n
            _≤ n - 1 := by simp

    have eq_top : f (i', k+1) = g (i', k+1) := by sorry

    have eq_bot : f (i' + 2, k) = g (i' + 2, k) := by sorry

    have eq_left : f (i' + 1, k) = g (i' + 1, k) := by exact ih

    calc f (i' + 1, k + 1) = f (i' + 1, k + 1) * f (i' + 1, k) * (f (i' + 1, k))⁻¹ := by rw[mul_inv_cancel_right₀ nzf (f (i' + 1, k + 1))]
    _= ( f (i' + 1, k) * f (i' + 1, k + 1) - 1 + 1) * (f (i' + 1, k))⁻¹ := by ring
    _= ( f (i' + 2,k)*f (i',k+1) + 1) * (f (i' + 1, k))⁻¹ := by rw[hf.diamond i' k i_leq_n_sub_one]
    _= ( g (i' + 2, k)*g (i',k+1) + 1) * (g (i' + 1, k))⁻¹ := by rw[eq_left, eq_top, eq_bot]
    _= ( g (i' + 1, k) * g (i' + 1, k + 1) - 1 + 1) * (g (i' + 1, k))⁻¹ := by rw[hg.diamond i' k i_leq_n_sub_one]
    _= g (i' + 1, k + 1) *  g (i' + 1, k) * (g (i' + 1, k))⁻¹ := by ring
    _= g (i' + 1, k + 1) := by rw[mul_inv_cancel_right₀ nzg (g (i' + 1, k + 1))]



lemma testEqualPattern1 (F : Type*) [Field F] (f g : ℕ×ℕ → F) (n: ℕ) (hf : nzPattern_n F f n) (hg : nzPattern_n F g n) (h : ∀ i, i ≤ n → f (i,0) = g (i,0)) : f = g := by
  have diamond_right_eq (i' k : ℕ)( eq_left : f (i' + 1, k) = g (i' + 1, k)) (eq_top : f (i', k+1) = g (i', k+1))(eq_bot : f (i' + 2, k) = g (i' + 2, k)) : f (i' + 1, k + 1)= g (i' + 1, k + 1) := by
    have one_leq_i_plus_1 : 1 ≤ i' + 1 :=
      calc 1 ≤ 0 + 1 := by simp
            _≤ i'+ 1 := Nat.succ_le_succ (Nat.zero_le i')

    by_cases i_plus_one_geq_n_plus_one : i' + 1 ≥ n+1

    have this := hf.botBordZeros_n (i'+1) (k+1) (by linarith)
    have that := hg.botBordZeros_n (i'+1) (k+1) (by linarith)
    rw[this,that]

    have i_plus_one_leq_n : i'+ 1 ≤ n := by linarith
    have nzf : f (i' + 1, k) ≠ 0 := by apply hf.non_zero (i'+1) k one_leq_i_plus_1 i_plus_one_leq_n
    have nzg : g (i' + 1, k) ≠ 0 := by apply hg.non_zero (i'+1) k one_leq_i_plus_1 i_plus_one_leq_n

    have i_leq_n_sub_one : i' ≤ n - 1 :=
      calc i'≤ (i'+1).pred := by simp
            _≤ (n).pred :=  Nat.pred_le_pred i_plus_one_leq_n
            _≤ n - 1 := by simp

    calc f (i' + 1, k + 1) = f (i' + 1, k + 1) * f (i' + 1, k) * (f (i' + 1, k))⁻¹ := by rw[mul_inv_cancel_right₀ nzf (f (i' + 1, k + 1))]
    _= ( f (i' + 1, k) * f (i' + 1, k + 1) - 1 + 1) * (f (i' + 1, k))⁻¹ := by ring
    _= ( f (i' + 2,k)*f (i',k+1) + 1) * (f (i' + 1, k))⁻¹ := by rw[hf.diamond i' k i_leq_n_sub_one]
    _= ( g (i' + 2, k)*g (i',k+1) + 1) * (g (i' + 1, k))⁻¹ := by rw[eq_left, eq_top, eq_bot]
    _= ( g (i' + 1, k) * g (i' + 1, k + 1) - 1 + 1) * (g (i' + 1, k))⁻¹ := by rw[hg.diamond i' k i_leq_n_sub_one]
    _= g (i' + 1, k + 1) *  g (i' + 1, k) * (g (i' + 1, k))⁻¹ := by ring
    _= g (i' + 1, k + 1) := by rw[mul_inv_cancel_right₀ nzg (g (i' + 1, k + 1))]

    --Have proved that eq_top, eq_left, eq_bot gives equality at the right of the diamond
    -- Aim to inductively prove these eq_top, eq_left, eq_bot


  funext ⟨i, m⟩

  def P t := f (t/n, t%n)


  induction m with
  | zero =>
    by_cases ileqn : i ≤ n
    exact h i ileqn
    have this := hf.botBordZeros_n i 0 (by linarith)
    --have that : g (i,0)=0 := by exact pattern_n.botBordZeros_n 0 i
    have that := hg.botBordZeros_n i 0 (by linarith)
    rw[this,that]

  | succ k ih =>
    induction i with
    | zero =>
    rw[hf.topBordZeros (k+1), hg.topBordZeros (k+1)]

    | succ i' ih' =>
    apply diamond_right_eq
    exact ih
    exact ih'




--/
