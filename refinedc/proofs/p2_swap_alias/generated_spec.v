From refinedc.typing Require Import typing.
From c_itp_refinedc.p2_swap_alias Require Import generated_code.
From caesium Require Import builtins_specs.
Set Default Proof Using "Type".

(* Generated from [p2_swap_alias.c]. *)
Section spec.
  Context `{!typeG Σ} `{!globalG Σ}.

  (* Specifications for function [__builtin_ffsll]. *)
  Definition type_of___builtin_ffsll  :=
    fn(∀ x : Z; (x @ (int (u64))); True)
      → ∃ () : (), (((Z_least_significant_one x + 1)%Z) @ (int (i32))); True.

  (* Specifications for function [swap]. *)
  Definition type_of_swap  :=
    fn(∀ (p, x) : loc * Z; (p @ (&own (x @ (int (i32))))), (p @ (&own (place (p)))); True)
      → ∃ () : (), (void); (p ◁ₗ (x @ (int (i32)))).
End spec.
