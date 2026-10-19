theory P1
imports "AutoCorres2.AutoCorres"
begin
install_C_file "p1_abs.c"
autocorres [ts_rules = nondet] "p1_abs.c"
context p1_abs_global_addresses begin
thm abs_val'_def
lemma abs_val_correct:
  assumes "-2147483648 < x" "x \<le> 2147483647"
  shows "abs_val' x \<bullet> s \<lbrace> \<lambda>Res r _. r = abs x \<rbrace>"
  unfolding abs_val'_def
  apply runs_to_vcg
  subgoal using assms by (simp add: INT_MAX_def; linarith)
  subgoal by simp
  done
ML \<open>val _ = if null (Thm_Deps.all_oracles [@{thm abs_val_correct}]) then
  writeln "AUDIT: abs_val_correct has no oracle dependencies" else error "Oracle dependency detected"\<close>
end
end
