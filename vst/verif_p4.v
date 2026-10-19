Require Import VST.floyd.proofauto.
Require Import CPrograms.p4_binary_search.
#[export] Instance CompSpecs : compspecs. make_compspecs prog. Defined.
Definition Vprog : varspecs. mk_varspecs prog. Defined.
Lemma div_two_repr : forall d, 0 <= d <= Int.max_signed ->
  Int.divs (Int.repr d) (Int.repr 2) = Int.repr (d/2).
Proof.
  intros. unfold Int.divs.
  rewrite !Int.signed_repr by rep_lia.
  rewrite Z.quot_div_nonneg by lia. reflexivity.
Qed.
Definition search_spec :=
 DECLARE _binary_search
 WITH a : val, xs : list Z, n : Z, key : Z
 PRE [tptr tint, tint, tint]
   PROP (0 <= n <= Int.max_signed; Zlength xs = n;
     Int.min_signed <= key <= Int.max_signed;
     Forall (fun x => Int.min_signed <= x <= Int.max_signed) xs;
     forall i j, 0 <= i /\ i <= j /\ j < n -> Znth i xs <= Znth j xs)
   PARAMS (a; Vint (Int.repr n); Vint (Int.repr key))
   SEP (data_at Tsh (tarray tint n) (map (fun x => Vint (Int.repr x)) xs) a)
 POST [tint] EX res : Z,
   PROP (-1 <= res < n;
     0 <= res -> Znth res xs = key;
     res = -1 <-> forall i, 0 <= i < n -> Znth i xs <> key)
   RETURN (Vint (Int.repr res))
   SEP (data_at Tsh (tarray tint n) (map (fun x => Vint (Int.repr x)) xs) a).
Definition Gprog : funspecs := ltac:(with_library prog [search_spec]).
Lemma body_search : semax_body Vprog Gprog f_binary_search search_spec.
Proof.
  start_function. forward. forward.
  forward_while
    (EX lo : Z, EX hi : Z,
      PROP (0 <= lo /\ lo <= hi /\ hi <= n;
        forall i, 0 <= i < lo -> Znth i xs < key;
        forall i, hi <= i < n -> key < Znth i xs)
      LOCAL (temp _a a; temp _n (Vint (Int.repr n));
        temp _key (Vint (Int.repr key));
        temp _lo (Vint (Int.repr lo)); temp _hi (Vint (Int.repr hi)))
      SEP (data_at Tsh (tarray tint n) (map (fun x => Vint (Int.repr x)) xs) a)).
  - Exists 0 n. entailer!; intros; lia.
  - entailer!.
  - assert (Hm : lo <= lo+(hi-lo)/2 < hi) by
      (pose proof (Z.div_pos (hi-lo) 2 ltac:(lia) ltac:(lia));
       pose proof (Z.div_lt_upper_bound (hi-lo) 2 (hi-lo) ltac:(lia) ltac:(lia)); lia).
    forward. { entailer!.
      rewrite div_two_repr by rep_lia.
      rewrite Int.signed_repr by rep_lia.
      split; [rep_lia | intros [_ Hb]; discriminate]. }
    rewrite sub_repr, div_two_repr, add_repr by rep_lia.
    forward. forward_if.
    + forward. Exists (lo+(hi-lo)/2). entailer!.
      assert (Hb : Int.min_signed <= Znth (lo+(hi-lo)/2) xs <= Int.max_signed)
        by (apply Forall_Znth; auto; lia).
      change (Int.repr (Znth (lo+(hi-lo)/2) xs) = Int.repr key) in H7.
      apply (f_equal Int.signed) in H7.
      rewrite !Int.signed_repr in H7 by lia.
      split; [auto | split; [lia | intro Ha; exfalso; apply (Ha (lo+(hi-lo)/2) ltac:(lia)); auto]].
    + forward. forward_if.
      * forward. { entailer!.
          change (Int.min_signed <= Int.signed (Int.repr (lo+(hi-lo)/2)) + 1 <= Int.max_signed).
          rewrite Int.signed_repr by rep_lia. rep_lia. }
        Exists (lo+(hi-lo)/2+1,hi). entailer!.
        split; [lia | split; [lia |]]. intros i Hi.
        assert (Hb : Int.min_signed <= Znth (lo+(hi-lo)/2) xs <= Int.max_signed)
          by (apply Forall_Znth; auto; lia).
        change (Int.signed (Int.repr (Znth (lo+(hi-lo)/2) xs)) < key) in H8.
        rewrite Int.signed_repr in H8 by lia.
        pose proof (H3 i (lo+(hi-lo)/2) ltac:(lia)). lia.
      * forward. Exists (lo,lo+(hi-lo)/2). entailer!.
        split; [lia | split; [lia |]]. intros i Hi.
        assert (Hb : Int.min_signed <= Znth (lo+(hi-lo)/2) xs <= Int.max_signed)
          by (apply Forall_Znth; auto; lia).
        change (Int.signed (Int.repr (Znth (lo+(hi-lo)/2) xs)) >= key) in H8.
        rewrite Int.signed_repr in H8 by lia.
        change (Int.repr (Znth (lo+(hi-lo)/2) xs) <> Int.repr key) in H7.
        assert (Hneq : Znth (lo+(hi-lo)/2) xs <> key) by congruence.
        pose proof (H3 (lo+(hi-lo)/2) i ltac:(lia)). lia.
  - forward. Exists (-1). entailer!.
    split; [|auto]. intros _ i Hi.
    destruct (Z_lt_dec i lo).
    + pose proof (H5 i ltac:(lia)). lia.
    + pose proof (H6 i ltac:(lia)). lia.
Qed.
Print Assumptions body_search.
