From refinedc.typing Require Import typing.
From c_itp_refinedc.p2_swap Require Import generated_code.
From c_itp_refinedc.p2_swap Require Import generated_spec.
From caesium Require Import builtins_specs.
Set Default Proof Using "Type".

(* Generated from [p2_swap.c]. *)
Section proof_swap.
  Context `{!typeG Σ} `{!globalG Σ}.

  (* Typing proof for [swap]. *)
  Lemma type_swap  :
    ⊢ typed_function impl_swap (type_of_swap ).
  Proof.
    Local Open Scope printing_sugar.
    start_function "swap" ([[[p q] x] y]) => arg_a arg_b local_t.
    prepare_parameters (p q x y).
    split_blocks ((
      ∅
    )%I : gmap label (iProp Σ)) (
      @nil Prop
    ).
    - repeat liRStep; liShow.
      all: print_typesystem_goal "swap" "#0".
    Unshelve. all: unshelve_sidecond; sidecond_hook; prepare_sideconditions; normalize_and_simpl_goal; try solve_goal; unsolved_sidecond_hook.
    all: print_sidecondition_goal "swap".
    Unshelve. all: try done; try apply: inhabitant; print_remaining_shelved_goal "swap".
  Qed.
End proof_swap.
