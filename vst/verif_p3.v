Require Import VST.floyd.proofauto.
Require Import CPrograms.p3_sum.
#[export] Instance CompSpecs : compspecs. make_compspecs prog. Defined.
Definition Vprog : varspecs. mk_varspecs prog. Defined.
Definition sumZ : list Z -> Z := fold_right Z.add 0.
Lemma sumZ_app : forall a b, sumZ (a++b) = sumZ a + sumZ b.
Proof. intros. induction a; simpl; lia. Qed.
Lemma prefix_step : forall xs i,
  0 <= i < Zlength xs ->
  sumZ (sublist 0 (i+1) xs) = sumZ (sublist 0 i xs) + Znth i xs.
Proof.
  intros. rewrite (sublist_split 0 i (i+1)) by lia.
  rewrite sumZ_app, (sublist_one i) by lia. simpl. lia.
Qed.
Definition sum_spec :=
 DECLARE _sum_array
 WITH a : val, xs : list Z, n : Z
 PRE [tptr tint, tint]
   PROP (0 <= n <= Int.max_signed; Zlength xs = n;
     Forall (fun x => Int.min_signed <= x <= Int.max_signed) xs;
     forall k, 0 <= k <= n ->
       Int.min_signed <= sumZ (sublist 0 k xs) <= Int.max_signed)
   PARAMS (a; Vint (Int.repr n))
   SEP (data_at Tsh (tarray tint n) (map (fun x => Vint (Int.repr x)) xs) a)
 POST [tint]
   PROP () RETURN (Vint (Int.repr (sumZ xs)))
   SEP (data_at Tsh (tarray tint n) (map (fun x => Vint (Int.repr x)) xs) a).
Definition Gprog : funspecs := ltac:(with_library prog [sum_spec]).
Lemma body_sum : semax_body Vprog Gprog f_sum_array sum_spec.
Proof.
  start_function. forward. forward.
  forward_while
    (EX i : Z,
      PROP (0 <= i <= n)
      LOCAL (temp _a a; temp _n (Vint (Int.repr n));
        temp _i (Vint (Int.repr i));
        temp _s (Vint (Int.repr (sumZ (sublist 0 i xs)))))
      SEP (data_at Tsh (tarray tint n) (map (fun x => Vint (Int.repr x)) xs) a)).
  - Exists 0. entailer!.
  - entailer!.
  - assert (Hi : 0 <= i < Zlength xs) by lia.
    assert (Hs := H2 (i+1) ltac:(lia)).
    rewrite prefix_step in Hs by lia.
    assert (Hsi := H2 i ltac:(lia)).
    assert (Hx : Int.min_signed <= Znth i xs <= Int.max_signed)
      by (apply Forall_Znth; auto; lia).
    forward. forward.
    forward.
    Exists (i+1). entailer!.
    rewrite prefix_step by lia. reflexivity.
  - forward. entailer!.
    autorewrite with sublist in *. reflexivity.
Qed.
Print Assumptions body_sum.
