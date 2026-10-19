From refinedc.typing Require Import typing.
From c_itp_refinedc.p3_sum_broken Require Import generated_code.
From c_itp_refinedc.p3_sum_broken Require Import generated_spec.
From caesium Require Import builtins_specs.
From c_itp_refinedc.p3_sum_broken Require Import sum_extra.
Set Default Proof Using "Type".

(* Generated from [p3_sum_broken.c]. *)
Section proof_sum_array.
  Context `{!typeG Σ} `{!globalG Σ}.

  (* Typing proof for [sum_array]. *)
  Lemma type_sum_array  :
    ⊢ typed_function impl_sum_array (type_of_sum_array ).
  Proof.
    Local Open Scope printing_sugar.
    start_function "sum_array" ([[p xs] n]) => arg_a arg_n local_i local_s.
    prepare_parameters (p xs n).
    split_blocks ((
      <[ "#1" :=
        ∃ j : nat,
        arg_a ◁ₗ (p @ (&own (array (i32) (xs `at_type` int i32)))) ∗
        arg_n ◁ₗ (n @ (int (i32))) ∗
        local_i ◁ₗ (j @ (int (i32))) ∗
        local_s ◁ₗ ((sumZ (take j xs) + 1) @ (int (i32))) ∗
        ⌜(j ≤ n)%nat⌝
    ]> $
      ∅
    )%I : gmap label (iProp Σ)) (
      @nil Prop
    ).
    - repeat liRStep; liShow.
      all: print_typesystem_goal "sum_array" "#0".
    - repeat liRStep; liShow.
      all: print_typesystem_goal "sum_array" "#1".
    Unshelve. all: unshelve_sidecond; sidecond_hook; prepare_sideconditions; normalize_and_simpl_goal; try solve_goal; unsolved_sidecond_hook.
    all: try by apply: prefix_step; solve_goal.
    all: try by pose proof (prefix_step xs j y H6); pose proof (H (S j) ltac:(lia)); lia.
    all: try by rewrite Nat.add_1_r; symmetry; apply prefix_step.
    all: print_sidecondition_goal "sum_array".
    Unshelve. all: try done; try apply: inhabitant; print_remaining_shelved_goal "sum_array".
  Qed.
End proof_sum_array.
