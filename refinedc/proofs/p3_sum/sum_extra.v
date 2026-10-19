From refinedc.typing Require Import typing.
Definition sumZ : list Z -> Z := foldr Z.add 0.
Lemma sumZ_app xs ys : sumZ (xs ++ ys) = sumZ xs + sumZ ys.
Proof. induction xs; simpl; lia. Qed.
Lemma prefix_step xs i x :
  xs !! i = Some x ->
  sumZ (take (S i) xs) = sumZ (take i xs) + x.
Proof.
  revert i. induction xs; intros [|i] H; simpl in *; try discriminate.
  - inversion H. lia.
  - rewrite (IHxs i H). lia.
Qed.
