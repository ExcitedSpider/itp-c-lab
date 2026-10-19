From refinedc.typing Require Import typing.
From c_itp_refinedc.p4_binary_search Require Import generated_code.
From caesium Require Import builtins_specs.
Set Default Proof Using "Type".

(* Generated from [p4_binary_search.c]. *)
Section spec.
  Context `{!typeG Σ} `{!globalG Σ}.

  (* Specifications for function [__builtin_ffsll]. *)
  Definition type_of___builtin_ffsll  :=
    fn(∀ x : Z; (x @ (int (u64))); True)
      → ∃ () : (), (((Z_least_significant_one x + 1)%Z) @ (int (i32))); True.

  (* Specifications for function [binary_search]. *)
  Definition type_of_binary_search  :=
    fn(∀ (p, xs, n, key) : loc * (list Z) * nat * Z; (p @ (&own (array (i32) (xs `at_type` int i32)))), (n @ (int (i32))), (key @ (int (i32))); ⌜n = length xs⌝ ∗ ⌜∀ i j x y, (i ≤ j)%nat → xs !! i = Some x → xs !! j = Some y → x ≤ y⌝)
      → ∃ res : Z, (res @ (int (i32))); ⌜(-1 ≤ res < n)%Z⌝ ∗ ⌜0 ≤ res → xs !! Z.to_nat res = Some key⌝ ∗ ⌜res = -1 ↔ ∀ i, xs !! i ≠ Some key⌝ ∗ (p ◁ₗ (array (i32) (xs `at_type` int i32))).
End spec.
