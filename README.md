# Outerplanarity from the Z-polynomial of a graphic matroid

Research note by Steve Raj, dated November 25, 2026. The [original manuscript](Outerplanarity.pdf) is a working draft and has yet to undergo formal peer review.

## Outerplanarity recognition

Let $G$ be a finite simple 2-connected graph on $n \ge 3$ vertices. Write $Z_G(t)$ for the $Z$-polynomial of its cycle matroid and $b(G)$ for its number of bonds, meaning minimal nonempty edge cuts. The note proves that $[t]Z_G(t)=b(G)\ge\binom n2$ and that the following are equivalent.

1. $G$ is outerplanar.
2. $Z_G(t)=N_n(t)$, the Narayana polynomial of order $n$.
3. $[t]Z_G(t)=\binom n2$.

The forward implication uses the matroid deletion formula to remove noncrossing diagonals from the outer boundary cycle. For the converse, the proof counts connected vertex bipartitions, shows that the excess over $\binom n2$ is monotone under open ear additions, and shows positive excess on subdivisions of $K_4$ and $K_{2,3}$.

## Ribbon matroid Narayana theorem

If $M$ is a connected ribbon lattice path matroid of rank $r$, then

$$
Z_M(t)=N_{r+1}(t)=\sum_{j=0}^{r}\frac{1}{r+1}\binom{r+1}{j}\binom{r+1}{j+1}t^j.
$$

Its $r$ roots are simple and negative. The manuscript uses the multi-fan representation and reduces the simplified cycle matroid to a polygon. A Jacobi polynomial identity gives the root statement.

## Lean verification

The historical [Lean source](Ribbon.lean) and [compilation and axiom audit](LeanAudit.log) accompany the manuscript. The recorded run used Lean 4.19.0 and Mathlib commit `c44e0c8ee63ca166450922a373c7409c5d26b00b`.

- `surviving_side_edge` establishes an abstract path and component-label lemma.
- `no_top_product_term` establishes the arithmetic degree bound used in the product argument.
- `delete_chords` iterates a local deletion equality supplied as an explicit hypothesis.
- Four concrete ribbon examples check coefficient lists produced by the file's finite computation using kernel reduction. Its agreement with the abstract matroid $Z$-polynomial in general remains outside the scope of the audit.

The audit reports only standard Lean axioms across these declarations. The conventional proofs in the manuscript cover the local matroid $Z$-deletion equality, the universal ribbon identity, its root statement, and the outerplanarity recognition theorem. Formal verification of those general results remains open in this repository. The audit's absolute path refers to the original checking environment. The [checksums](SHA256SUMS) cover the three historical research files.

To replay the historical check, use Elan and Git, starting from the repository root.

```sh
note_dir="$PWD"
git clone https://github.com/leanprover-community/mathlib4.git mathlib-audit
cd mathlib-audit
git checkout c44e0c8ee63ca166450922a373c7409c5d26b00b
lake exe cache get
lake env lean -DwarningAsError=true -o /tmp/outerplanarity-ribbon.olean "$note_dir/Ribbon.lean"
```

## Acknowledgments

Per Alexandersson posed the ribbon conjecture. [SymCat records the conjecture and both solutions](https://www.symmetricfunctions.com/schubertMatroidZ.htm#ribbonMatroidZNarayana).

ProgramComputer independently proved the ribbon conjecture on November 25, 2026. See the [dated independent proof](https://github.com/ProgramComputer/open-math-research/blob/d27bf1897bff2f426d57bea5efdbc9fca6f17d4f/topics/ribbon-matroids/proof.md), its [formal verification scope](https://github.com/ProgramComputer/open-math-research/blob/d27bf1897bff2f426d57bea5efdbc9fca6f17d4f/topics/ribbon-matroids/lean/README.md), and the [associated Zenodo archive](https://doi.org/10.5281/zenodo.24564954).

This project used extensive assistance from OpenAI Codex and ChatGPT in a user-directed research experiment. As disclosed in the manuscript, Codex developed arguments, searched the literature, implemented checks, and drafted the note. Steve Raj is the human contributor.

## Citation

See [CITATION.cff](CITATION.cff). November 25, 2026 is the manuscript date. The GitHub release records the public release date.
