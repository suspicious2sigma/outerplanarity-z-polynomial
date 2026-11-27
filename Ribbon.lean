import Mathlib.Logic.Relation
import Mathlib.Data.Nat.Choose.Basic
import Mathlib.Data.Complex.Basic

namespace Ribbon

/-- A north step is true. The two boundaries of a connected ribbon are
    E w N and N w E, where w is the word between their first and last steps. -/
def lower (w : List Bool) := false :: (w ++ [true])
def rankOfWord (w : List Bool) := 1 + w.count true

def pop (s length : Nat) : Nat :=
  ((List.range length).filter fun i => s.testBit i).length

def bases (w : List Bool) : List Nat :=
  let L := lower w
  let d := L.length
  (List.range (2^d)).filter fun s =>
    pop s d == rankOfWord w &&
    (List.range (d+1)).all fun i =>
      let h := (L.take i).count true
      decide (h ≤ pop s i ∧ pop s i ≤ h + (if 0 < i ∧ i < d then 1 else 0))

structure Flat where
  mask : Nat
  rk : Nat
deriving Repr, DecidableEq

def flats (w : List Bool) : List Flat :=
  let d := w.length+2
  let bs := bases w
  let rk := fun s => bs.foldl (fun m b => max m (pop (s &&& b) d)) 0
  ((List.range (2^d)).filter fun s => (List.range d).all fun i =>
    s.testBit i || decide (rk s < rk (s ||| (2^i)))).map fun s => ⟨s, rk s⟩

structure Row extends Flat where
  kl : List Int
deriving Repr

/-- Sum of the shifted KL polynomials in the known part of the interval. -/
def coeff (rows : List Row) (f : Flat) (i : Nat) : Int :=
  (rows.map fun g =>
    let shift := g.rk - f.rk
    if f.mask &&& g.mask == f.mask && shift ≤ i then g.kl[i-shift]?.getD 0 else 0).sum

/-- Sorted masks put every strict superset later. Palindromicity recovers
    the KL coefficients from the upper half of the known sum. -/
def zVector (w : List Bool) : List Int :=
  let r := rankOfWord w
  let rows := (flats w).foldr (fun f tail =>
    let c := r-f.rk
    let kl := if c == 0 then [1] else
      (List.range ((c+1)/2)).map fun i => coeff tail f (c-i) - coeff tail f i
    {toFlat := f, kl := kl : Row} :: tail) []
  (List.range (r+1)).map (coeff rows ⟨0,0⟩)

def narayana (r : Nat) : List Int :=
  (List.range (r+1)).map fun i =>
    (Nat.choose (r+1) i * Nat.choose (r+1) (i+1) / (r+1) : Nat)

def value (cs : List Int) (z : ℂ) : ℂ :=
  cs.foldr (fun (c : Int) (p : ℂ) => (c : ℂ) + z*p) 0

/-- Both claims for the original lattice path encoding. -/
def AlexanderssonRibbonConjecture : Prop :=
  ∀ w : List Bool, zVector w = narayana (rankOfWord w) ∧
    ∀ z : ℂ, value (zVector w) z = 0 → z.im = 0

/-- The graph step on either side of a shared edge. The path avoids the
    shared edge. Old and new component labels refer to F and F ∪ {e}.
    Flat closure says that a side edge collapsed in the larger partition
    already belonged to F, hence its old endpoint labels agree. -/
theorem surviving_side_edge {V A B : Type} (edge : V → V → Prop)
    (oldLabel : V → A) (newLabel : V → B) {u v : V}
    (path : Relation.ReflTransGen edge u v) (sep : oldLabel u ≠ oldLabel v)
    (flat : ∀ x y, edge x y → newLabel x = newLabel y → oldLabel x = oldLabel y) :
    ∃ x y, edge x y ∧ newLabel x ≠ newLabel y := by
  classical
  by_contra absent
  have eqEdge : ∀ x y, edge x y → oldLabel x = oldLabel y := by
    intro x y hxy
    apply flat x y hxy
    by_contra h
    exact absent ⟨x, y, hxy, h⟩
  apply sep
  clear sep
  induction path with
  | refl => rfl
  | tail _ h ih => exact ih.trans (eqEdge _ _ h)

/-- Degree argument for vanishing of the top KL coefficient in a
    positive-rank direct sum of odd total rank, for each product monomial. -/
theorem no_top_product_term (r₁ r₂ i j top : Nat)
    (hi : 2*i < r₁) (hj : 2*j < r₂) (h : r₁+r₂ = 2*top+1) :
    i+j < top := by omega

/-- Iteration of a local invariant over a list of polygon chords.
    The local deletion equality and the base computation are premises. -/
theorem delete_chords {A B : Type} (Z : List A → B) (ok : A → Prop)
    (localEq : ∀ a ds, ok a → (∀ d ∈ ds, ok d) → Z (a::ds) = Z ds)
    (ds : List A) (allowed : ∀ d ∈ ds, ok d) : Z ds = Z [] := by
  induction ds with
  | nil => rfl
  | cons a ds ih =>
    have htail : ∀ d ∈ ds, ok d := fun d hd => allowed d (List.mem_cons_of_mem _ hd)
    exact (localEq a ds (allowed a (List.mem_cons_self ..)) htail).trans (ih htail)

set_option maxHeartbeats 30000000
set_option maxRecDepth 100000
theorem unit_square : zVector [] = [1,1] := by decide
theorem rank_three_hook : zVector [true,true,false] = [1,6,6,1] := by decide
theorem rank_three_staircase : zVector [true,false,true] = [1,6,6,1] := by decide
theorem rank_four_circuit : zVector [true,true,true] = [1,10,20,10,1] := by decide

#print axioms surviving_side_edge
#print axioms no_top_product_term
#print axioms delete_chords
#print axioms unit_square
#print axioms rank_three_hook
#print axioms rank_three_staircase
#print axioms rank_four_circuit
end Ribbon
