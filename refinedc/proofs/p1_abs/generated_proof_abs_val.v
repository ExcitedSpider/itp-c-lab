From refinedc.typing Require Import typing.
From c_itp_refinedc.p1_abs Require Import generated_code.
From c_itp_refinedc.p1_abs Require Import generated_spec.
From caesium Require Import builtins_specs.
Set Default Proof Using "Type".

(* Generated from [p1_abs.c]. *)
Section proof_abs_val.
  Context `{!typeG Σ} `{!globalG Σ}.

  (* Typing proof for [abs_val]. *)
  Lemma type_abs_val  :
    ⊢ typed_function impl_abs_val (type_of_abs_val ).
  Proof.
    Local Open Scope printing_sugar.
    start_function "abs_val" (x) => arg_x.
    prepare_parameters (x).
    split_blocks ((
      ∅
    )%I : gmap label (iProp Σ)) (
      @nil Prop
    ).
    - repeat liRStep; liShow.
      all: print_typesystem_goal "abs_val" "#0".
    Unshelve. all: unshelve_sidecond; sidecond_hook; prepare_sideconditions; normalize_and_simpl_goal; try solve_goal; unsolved_sidecond_hook.
    all: print_sidecondition_goal "abs_val".
    Unshelve. all: try done; try apply: inhabitant; print_remaining_shelved_goal "abs_val".
  Qed.
End proof_abs_val.
