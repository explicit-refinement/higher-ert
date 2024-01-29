import Mathlib.Data.Set.Basic
import Mathlib.Logic.Relator

structure PER {α} (r: α -> α -> Prop): Prop where
  symm: ∀{x y: α}, r x y -> r y x
  trans: ∀{x y z: α}, r x y -> r y z -> r x z

theorem PER.refl_left (A: PER r) (Hab: r a b): r a a
  := A.trans Hab (A.symm Hab)

theorem PER.refl_right (A: PER r) (Hab: r a b): r b b
  := A.trans (A.symm Hab) Hab

theorem PER.of_rel_subsingleton (r: α -> α -> Prop) (Hr: ∀{x y}, r x y -> x = y): PER r
  where
  symm Hxy := Hr Hxy ▸ Hr Hxy ▸ Hxy
  trans Hxy Hyz := Hr Hxy ▸ Hyz

theorem PER.of_subsingleton [S: Subsingleton α] (r: α -> α -> Prop): PER r
  := PER.of_rel_subsingleton r (λ_ => S.allEq _ _)

def PER.carrier {α} {r: α -> α -> Prop} (_: PER r)
  : Set α := λx: α => r x x

def PER.lift_fun {α β} {r: α -> α -> Prop} {s: β -> β -> Prop}
  (A: PER r) (B: PER s): PER (Relator.LiftFun r s) where
  symm Hxy _ _ Haa' := B.symm (Hxy (A.symm Haa'))
  trans Hrsxy Hrsyz _ _ Hraa' :=
    have Hraa := A.refl_left Hraa'
    have Hsxaya := Hrsxy Hraa
    have Hsyaza' := Hrsyz Hraa';
    B.trans Hsxaya Hsyaza'

def CRelToRel
  (r: α -> α -> Prop)
  (s: α -> β -> β -> Prop)
  : ((a: α) -> β) -> ((a: α) -> β) -> Prop
  := λf g => ∀{a a': α}, r a a' -> s a (f a) (g a')

-- def PER.c_rel_to_rel {α β} {r: α -> α -> Prop} {s: α -> β -> β -> Prop}
--   (A: PER r)
--   (B: ∀a, PER (s a))
--   (Hs: ∀{a a': α}, r a a' -> s a = s a')
--   : PER (CRelToRel r s) where
--   symm Hab _ _ Haa' := sorry
--   trans Hrsxy Hrsyz _ _ Hraa' := sorry

def DRelToRel
  (r: α -> α -> Prop)
  (β: α -> Type _)
  (s: (a: α) -> (a': α) -> β a -> β a' -> Prop)
  : ((a: α) -> β a) -> ((a: α) -> β a) -> Prop
  := λf g => ∀{a a': α}, r a a' -> s a a' (f a) (g a')

def CDRelToRel
  (r: α -> α -> Prop)
  (β: α -> Type _)
  (Hβ: ∀{a a': α}, r a a' -> β a = β a')
  (s: (a: α) -> β a -> β a -> Prop)
  : ((a: α) -> β a) -> ((a: α) -> β a) -> Prop
  := λf g => ∀{a a': α}, (H: r a a') -> s a (f a) (Hβ H ▸ (g a'))

theorem Equivalence.toPER {α} {r: α -> α -> Prop}
  (E: Equivalence r): PER r where
  symm := E.symm
  trans := E.trans

theorem PER.refl_equivalence {α} {r: α -> α -> Prop}
  (P: PER r) (refl: ∀x, r x x)
  : Equivalence r where
  refl := refl
  symm := P.symm
  trans := P.trans

class PSetoid (α) where
  r: α -> α -> Prop
  isper: PER r

instance {α: Sort u} [PSetoid α] : HasEquiv α :=
  ⟨PSetoid.r⟩

theorem PSetoid.symm {α} [PSetoid α] {a b: α}: a ≈ b -> b ≈ a :=
  PSetoid.isper.symm

theorem PSetoid.trans {α} [PSetoid α] {a b c: α}: a ≈ b -> b ≈ c -> a ≈ c :=
  PSetoid.isper.trans

theorem PSetoid.refl_left {α} [PSetoid α] {a b: α}: a ≈ b -> a ≈ a :=
  PSetoid.isper.refl_left

theorem PSetoid.refl_right {α} [PSetoid α] {a b: α}: a ≈ b -> b ≈ b :=
  PSetoid.isper.refl_right

def PSetoid.carrier {α} (S: PSetoid α): Set α := λx: α => S.r x x

def PSetoid.reflSetoid {α} (S: PSetoid α) (refl: ∀x, S.r x x)
  : Setoid α where
  r := S.r
  iseqv := PER.refl_equivalence S.isper refl

def Setoid.toPSetoid {α} (S: Setoid α): PSetoid α where
  r := S.r
  isper := Equivalence.toPER S.iseqv
