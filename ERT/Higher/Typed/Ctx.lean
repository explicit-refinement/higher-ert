import ERT.Higher.Basic

namespace HERT

open World

structure Var where
  ty: Term
  world: World

structure Var.le (x y: Var): Prop where
  ty: x.ty = y.ty
  world: x.world ≤ y.world

instance Var.instPartialOrder: PartialOrder (Var) where
  le := le
  le_refl _ := ⟨rfl, le_refl _⟩
  le_trans _ _ _ l r := ⟨l.ty.trans r.ty, le_trans l.world r.world⟩
  le_antisymm
  | ⟨_, _⟩,  ⟨_, _⟩, l, r
    => by rw [Var.mk.injEq]; exact ⟨l.ty, le_antisymm l.world r.world⟩

inductive HasVar: List (Var) -> ℕ -> Term -> World -> Type where
  | head: ∀ {w w'} (Γ A), w'.le w -> HasVar (Var.mk A w :: Γ) 0 (A.wk Nat.succ) w'
  | tail: ∀ {Γ A v n w}, HasVar Γ n A w -> HasVar (v :: Γ) (n + 1) (A.wk Nat.succ) w

def HasVar.toGhost {Γ n A w}: @HasVar Γ n A w -> HasVar Γ n A ghost
  | head _ _A _ => head _ _ (World.le.ghost _)
  | tail H => tail H.toGhost
