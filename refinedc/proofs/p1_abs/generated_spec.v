From refinedc.typing Require Import typing.
From c_itp_refinedc.p1_abs Require Import generated_code.
From caesium Require Import builtins_specs.
Set Default Proof Using "Type".

(* Generated from [p1_abs.c]. *)
Section spec.
  Context `{!typeG Σ} `{!globalG Σ}.

  (* Specifications for function [__builtin_ffsll]. *)
  Definition type_of___builtin_ffsll  :=
    fn(∀ x : Z; (x @ (int (u64))); True)
      → ∃ () : (), (((Z_least_significant_one x + 1)%Z) @ (int (i32))); True.

  (* Specifications for function [abs_val]. *)
  Definition type_of_abs_val  :=
    fn(∀ x : Z; (x @ (int (i32))); ⌜min_int i32 < x⌝)
      → ∃ () : (), ((Z.abs x) @ (int (i32))); True.
End spec.
