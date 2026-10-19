From refinedc.typing Require Import typing.
From c_itp_refinedc.p5_reverse Require Import generated_code.
From caesium Require Import builtins_specs.
Set Default Proof Using "Type".

(* Generated from [p5_reverse.c]. *)
Section spec.
  Context `{!typeG Σ} `{!globalG Σ}.

  (* Definition of type [node_t]. *)
  Definition node_t_rec : ((list Z) → type) → ((list Z) → type) := (λ self xs,
    ((maybe2 cons xs) @ (optionalO (λ patt__,
      let x := patt__.1 in
      let xs := patt__.2 in
      &own (
        struct struct_node [@{type}
          (x @ (int (i32))) ;
          (self (xs))
        ]
      )
    ) null))
  )%I.
  Global Typeclasses Opaque node_t_rec.

  Global Instance node_t_rec_le : TypeMono node_t_rec.
  Proof. solve_type_proper. Qed.

  Definition node_t : rtype ((list Z)) := {|
    rty r__ := node_t_rec (type_fixpoint node_t_rec) r__
  |}.

  Lemma node_t_unfold (xs : (list Z)):
    (xs @ node_t)%I ≡@{type} (
      ((maybe2 cons xs) @ (optionalO (λ patt__,
        let x := patt__.1 in
        let xs := patt__.2 in
        &own (
          struct struct_node [@{type}
            (x @ (int (i32))) ;
            (xs @ node_t)
          ]
        )
      ) null))
    )%I.
  Proof. apply: (type_fixpoint_unfold2 node_t_rec). Qed.

  Definition node_t_simplify_hyp_place_inst_generated patt__ :=
    [instance simplify_hyp_place_eq _ _ (node_t_unfold patt__) with 100%N].
  Global Existing Instance node_t_simplify_hyp_place_inst_generated.
  Definition node_t_simplify_goal_place_inst_generated patt__ :=
    [instance simplify_goal_place_eq _ _ (node_t_unfold patt__) with 100%N].
  Global Existing Instance node_t_simplify_goal_place_inst_generated.

  Definition node_t_simplify_hyp_val_inst_generated patt__ :=
    [instance simplify_hyp_val_eq _ _ (node_t_unfold patt__) with 100%N].
  Global Existing Instance node_t_simplify_hyp_val_inst_generated.
  Definition node_t_simplify_goal_val_inst_generated patt__ :=
    [instance simplify_goal_val_eq _ _ (node_t_unfold patt__) with 100%N].
  Global Existing Instance node_t_simplify_goal_val_inst_generated.

  (* Specifications for function [__builtin_ffsll]. *)
  Definition type_of___builtin_ffsll  :=
    fn(∀ x : Z; (x @ (int (u64))); True)
      → ∃ () : (), (((Z_least_significant_one x + 1)%Z) @ (int (i32))); True.

  (* Specifications for function [reverse]. *)
  Definition type_of_reverse  :=
    fn(∀ xs : (list Z); (xs @ (node_t)); True)
      → ∃ () : (), ((rev xs) @ (node_t)); True.
End spec.

Global Typeclasses Opaque node_t_rec.
Global Typeclasses Opaque node_t.
