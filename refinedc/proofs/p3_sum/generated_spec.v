From refinedc.typing Require Import typing.
From c_itp_refinedc.p3_sum Require Import generated_code.
From caesium Require Import builtins_specs.
From c_itp_refinedc.p3_sum Require Import sum_extra.
Set Default Proof Using "Type".

(* Generated from [p3_sum.c]. *)
Section spec.
  Context `{!typeG Σ} `{!globalG Σ}.

  (* Specifications for function [__builtin_ffsll]. *)
  Definition type_of___builtin_ffsll  :=
    fn(∀ x : Z; (x @ (int (u64))); True)
      → ∃ () : (), (((Z_least_significant_one x + 1)%Z) @ (int (i32))); True.

  (* Specifications for function [sum_array]. *)
  Definition type_of_sum_array  :=
    fn(∀ (p, xs, n) : loc * (list Z) * nat; (p @ (&own (array (i32) (xs `at_type` int i32)))), (n @ (int (i32))); ⌜n = length xs⌝ ∗ ⌜∀ k, (k ≤ n)%nat → min_int i32 ≤ sumZ (take k xs) ≤ max_int i32⌝)
      → ∃ () : (), ((sumZ xs) @ (int (i32))); (p ◁ₗ (array (i32) (xs `at_type` int i32))).
End spec.
