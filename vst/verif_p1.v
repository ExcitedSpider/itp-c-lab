Require Import VST.floyd.proofauto.
Require Import CPrograms.p1_abs.
#[export] Instance CompSpecs : compspecs. make_compspecs prog. Defined.
Definition Vprog : varspecs. mk_varspecs prog. Defined.
Definition abs_spec :=
 DECLARE _abs_val
 WITH x : Z
 PRE [tint]
   PROP (Int.min_signed < x <= Int.max_signed)
   PARAMS (Vint (Int.repr x)) SEP ()
 POST [tint]
   PROP () RETURN (Vint (Int.repr (Z.abs x))) SEP ().
Definition Gprog : funspecs := ltac:(with_library prog [abs_spec]).
Lemma body_abs : semax_body Vprog Gprog f_abs_val abs_spec.
Proof.
  start_function.
  forward_if.
  - forward. entailer!.
    + change (-x <= 2147483647). change (-2147483648 < x <= 2147483647) in H. lia.
    + rewrite Z.abs_neq by lia. entailer!.
  - forward. entailer!. rewrite Z.abs_eq by lia. reflexivity.
Qed.
Print Assumptions body_abs.
