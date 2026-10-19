From refinedc.typing Require Import typing.
From c_itp_refinedc.p5_reverse Require Import generated_code.
From c_itp_refinedc.p5_reverse Require Import generated_spec.
From caesium Require Import builtins_specs.
Set Default Proof Using "Type".

(* Generated from [p5_reverse.c]. *)
Section proof_reverse.
  Context `{!typeG Σ} `{!globalG Σ}.

  (* Typing proof for [reverse]. *)
  Lemma type_reverse  :
    ⊢ typed_function impl_reverse (type_of_reverse ).
  Proof.
    Local Open Scope printing_sugar.
    start_function "reverse" (xs) => arg_l local_r local_next.
    prepare_parameters (xs).
    split_blocks ((
      <[ "#1" :=
        ∃ ys : list Z,
        ∃ zs : list Z,
        local_next ◁ₗ uninit void* ∗
        local_r ◁ₗ (ys @ (node_t)) ∗
        arg_l ◁ₗ (zs @ (node_t)) ∗
        ⌜xs = rev ys ++ zs⌝
    ]> $
      ∅
    )%I : gmap label (iProp Σ)) (
      @nil Prop
    ).
    - repeat liRStep; liShow.
      all: print_typesystem_goal "reverse" "#0".
    - repeat liRStep; liShow.
      all: print_typesystem_goal "reverse" "#1".
    Unshelve. all: unshelve_sidecond; sidecond_hook; prepare_sideconditions; normalize_and_simpl_goal; try solve_goal; unsolved_sidecond_hook.
    all: print_sidecondition_goal "reverse".
    Unshelve. all: try done; try apply: inhabitant; print_remaining_shelved_goal "reverse".
  Qed.
End proof_reverse.
