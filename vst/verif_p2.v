Require Import VST.floyd.proofauto.
Require Import CPrograms.p2_swap.
#[export] Instance CompSpecs : compspecs. make_compspecs prog. Defined.
Definition Vprog : varspecs. mk_varspecs prog. Defined.
Definition swap_separate_spec :=
 DECLARE _swap
 WITH a : val, b : val, x : int, y : int
 PRE [tptr tint, tptr tint]
   PROP () PARAMS (a;b)
   SEP (data_at Tsh tint (Vint x) a; data_at Tsh tint (Vint y) b)
 POST [tvoid]
   PROP () RETURN ()
   SEP (data_at Tsh tint (Vint y) a; data_at Tsh tint (Vint x) b).
Definition swap_alias_spec :=
 DECLARE _swap
 WITH p : val, x : int
 PRE [tptr tint, tptr tint]
   PROP () PARAMS (p;p) SEP (data_at Tsh tint (Vint x) p)
 POST [tvoid]
   PROP () RETURN () SEP (data_at Tsh tint (Vint x) p).
Definition Gprog : funspecs := ltac:(with_library prog [swap_separate_spec]).
Lemma body_swap_separate : semax_body Vprog Gprog f_swap swap_separate_spec.
Proof.
  start_function.
  forward. forward. forward. forward. entailer!.
Qed.
Lemma body_swap_alias : semax_body Vprog Gprog f_swap swap_alias_spec.
Proof.
  start_function.
  forward. forward. forward. forward. entailer!.
Qed.
Print Assumptions body_swap_separate.
Print Assumptions body_swap_alias.
