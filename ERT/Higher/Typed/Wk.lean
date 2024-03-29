import ERT.Higher.Typed.Basic

--TODO: Port to version from weakening utils

namespace HERT

inductive WkCtx: (ℕ -> ℕ) -> (Γ: List Var) -> (Δ: List Var) -> Type
  | nil (ρ): WkCtx ρ [] []
  | lift (A): WkCtx ρ Γ Δ -> w'.le w →
    WkCtx (liftWk ρ) (Var.mk (A.wk ρ) w :: Γ) (Var.mk A w' :: Δ)
  | step (A): WkCtx ρ Γ Δ -> WkCtx (stepWk ρ) (Var.mk A w :: Γ) Δ

def WkCtx.slift {ρ Γ Δ} (A w) (R: @WkCtx ρ Γ Δ):
  WkCtx (liftWk ρ) (Var.mk (A.wk ρ) w :: Γ) (Var.mk A w :: Δ) :=
  WkCtx.lift _ R (World.le.refl _)

def WkCtx.src {ρ Γ Δ} (_: @WkCtx ρ Γ Δ): List Var := Γ
def WkCtx.trg {ρ Γ Δ} (_: @WkCtx ρ Γ Δ): List Var := Δ

def WkCtx.ix {ρ Γ Δ} (_: @WkCtx ρ Γ Δ): ℕ -> ℕ := ρ

def HasVar.wk {ρ Γ Δ A n w}: @WkCtx ρ Γ Δ -> HasVar Δ n A w -> HasVar Γ (ρ n) (A.wk ρ) w
  | WkCtx.lift _ ρ H', head _ _ H => Term.wk_lift_succ _ _ ▸ head _ _ (H.trans H')
  | WkCtx.lift _ ρ _, tail v => Term.wk_lift_succ _ _ ▸ tail (v.wk ρ)
  | WkCtx.step _ ρ, v => Term.wk_step_succ _ _ ▸ tail (v.wk ρ)

theorem Term.IsSort.fv_zero {K w} (H: @IsSort K w): K.fv = 0 := by cases H <;> rfl

theorem Term.IsSort.eq_wk {K w} (H: @IsSort K w) (ρ: _): K.wk ρ = K := K.wk_closed (H.fv_zero)

theorem Term.IsSort.eq_wk' {K w} (H: @IsSort K w) (ρ ρ': _): K.wk ρ = K.wk ρ' :=
  (H.eq_wk ρ).trans (H.eq_wk ρ').symm

def Term.IsSort.wk {K w} (H: @IsSort K w) (ρ: _): IsSort (K.wk ρ) w := (H.eq_wk _).symm ▸ H

def Term.HasType.wk {ρ Γ Δ a A w} (R: @WkCtx ρ Γ Δ)
  : HasType Δ a A w -> HasType Γ (a.wk ρ) (A.wk ρ) w
  | var v HA HS => var (v.wk R) (HA.wk R) (HS.wk ρ)
  | pi HA HKA HB HKB =>
    pi (HA.wk R) (HKA.wk ρ) ((HKB.eq_wk' _ _) ▸ HB.wk (R.slift _ _)) (HKB.wk ρ)
  | unit _ _ => unit _ _
  | nat _ _ => nat _ _
  | prop _ => prop _
  | top _ => top _
  | bot _ => bot _
  | eq HA Ha Hb => eq (HA.wk R) (Ha.wk R) (Hb.wk R)
  | lam HA HKA Ht HB => lam (HA.wk R) (HKA.wk ρ) (Ht.wk (R.slift _ _)) (HB.wk (R.slift _ _))
  | app Hs Ht E => app (Hs.wk R) (Ht.wk R) (E ▸ Term.subst0_liftWk _ _ _)
