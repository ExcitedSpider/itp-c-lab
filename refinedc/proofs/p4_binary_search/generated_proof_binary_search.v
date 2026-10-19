From refinedc.typing Require Import typing.
From c_itp_refinedc.p4_binary_search Require Import generated_code.
From c_itp_refinedc.p4_binary_search Require Import generated_spec.
From caesium Require Import builtins_specs.
Set Default Proof Using "Type".

(* Generated from [p4_binary_search.c]. *)
Section proof_binary_search.
  Context `{!typeG Σ} `{!globalG Σ}.

  (* Typing proof for [binary_search]. *)
  Lemma type_binary_search  :
    ⊢ typed_function impl_binary_search (type_of_binary_search ).
  Proof.
    Local Open Scope printing_sugar.
    start_function "binary_search" ([[[p xs] n] key]) => arg_a arg_n arg_key local_lo local_mid local_hi.
    prepare_parameters (p xs n key).
    split_blocks ((
      <[ "#1" :=
        ∃ vl : nat,
        ∃ vh : nat,
        arg_a ◁ₗ (p @ (&own (array (i32) (xs `at_type` int i32)))) ∗
        arg_n ◁ₗ (n @ (int (i32))) ∗
        arg_key ◁ₗ (key @ (int (i32))) ∗
        local_mid ◁ₗ uninit (it_layout i32) ∗
        local_lo ◁ₗ (vl @ (int (i32))) ∗
        local_hi ◁ₗ (vh @ (int (i32))) ∗
        ⌜(vl ≤ vh ≤ n)%nat⌝ ∗
        ⌜∀ i x, (i < vl)%nat → xs !! i = Some x → x < key⌝ ∗
        ⌜∀ i x, (vh ≤ i)%nat → xs !! i = Some x → key < x⌝
    ]> $
      ∅
    )%I : gmap label (iProp Σ)) (
      @nil Prop
    ).
    - repeat liRStep; liShow.
      all: print_typesystem_goal "binary_search" "#0".
    - repeat liRStep; liShow.
      all: print_typesystem_goal "binary_search" "#1".
    Unshelve. all: unshelve_sidecond; sidecond_hook; prepare_sideconditions; normalize_and_simpl_goal; try solve_goal; unsolved_sidecond_hook.
    all: try by split; [intro; exfalso; solve_goal | intro Hnone; exfalso; apply (Hnone _ H14)].
    all: try by have Hxy : x ≤ y := H i (Z.to_nat (vl + (vh-vl) `quot` 2)) x y ltac:(solve_goal) H25 H14; lia.
    all: try by have Hyx : y ≤ x := H (Z.to_nat (vl + (vh-vl) `quot` 2)) i y x H22 H14 H23; lia.
    all: try by split; [intros _ i Hi; destruct (decide (i < vl)%nat) as [Hil|Hil]; [pose proof (H2 i key Hil Hi); lia | pose proof (H3 i key ltac:(lia) Hi); lia] | done].
    all: print_sidecondition_goal "binary_search".
    Unshelve. all: try done; try apply: inhabitant; print_remaining_shelved_goal "binary_search".
  Qed.
End proof_binary_search.
