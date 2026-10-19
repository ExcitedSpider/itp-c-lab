Require Import VST.floyd.proofauto.
Require Import CPrograms.p5_reverse.
#[export] Instance CompSpecs : compspecs. make_compspecs prog. Defined.
Definition Vprog : varspecs. mk_varspecs prog. Defined.
Definition tnode := Tstruct _node noattr.
Fixpoint listrep (xs : list int) (p : val) : mpred :=
  match xs with
  | nil => !! (p = nullval) && emp
  | x :: tl => EX q : val, data_at Tsh tnode (Vint x,q) p * listrep tl q
  end.
Arguments listrep xs p : simpl never.
Lemma listrep_local : forall xs p,
  listrep xs p |-- !! (is_pointer_or_null p /\ (p = nullval <-> xs = nil)).
Proof.
  induction xs; intros; unfold listrep; fold listrep.
  - entailer!. tauto.
  - Intros q. entailer!.
    assert (isptr p) by auto with field_compatible.
    split; intro He; [subst p; contradiction | discriminate].
Qed.
#[export] Hint Resolve listrep_local : saturate_local.
Lemma listrep_valid : forall xs p, listrep xs p |-- valid_pointer p.
Proof.
  intros. destruct xs; unfold listrep; fold listrep.
  - entailer!.
  - Intros q. auto with valid_pointer.
Qed.
#[export] Hint Resolve listrep_valid : valid_pointer.
Definition reverse_spec :=
 DECLARE _reverse
 WITH xs : list int, p : val
 PRE [tptr tnode] PROP () PARAMS (p) SEP (listrep xs p)
 POST [tptr tnode] EX q : val,
   PROP () RETURN (q) SEP (listrep (rev xs) q).
Definition Gprog : funspecs := ltac:(with_library prog [reverse_spec]).
Lemma body_reverse : semax_body Vprog Gprog f_reverse reverse_spec.
Proof.
  start_function. forward.
  forward_while
    (EX ys : list int, EX zs : list int, EX r : val, EX l : val,
      PROP (xs = rev ys ++ zs)
      LOCAL (temp _r r; temp _l l)
      SEP (listrep ys r; listrep zs l)).
  - Exists (@nil int) xs nullval p. unfold listrep at 2. entailer!.
  - entailer!.
  - destruct zs as [|z zs].
    + unfold listrep at 2. Intros. contradiction.
    + unfold listrep at 2; fold listrep. Intros q.
      forward. forward. forward. forward.
      Exists (z::ys,zs,l,q). entailer!.
      * simpl. rewrite <- app_assoc. reflexivity.
      * unfold listrep at 3; fold listrep. Exists r. cancel.
  - assert_PROP (zs = nil) by (entailer!; tauto). subst zs.
    forward. Exists r.
    rewrite app_nil_r, rev_involutive. entailer!. unfold listrep. entailer!.
Qed.
Print Assumptions body_reverse.
