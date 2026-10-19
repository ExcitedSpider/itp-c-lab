theory P2
imports "AutoCorres2.AutoCorres"
begin
install_C_file "../../programs/p2_swap.c"
autocorres [heap_abs_syntax, ts_rules = nondet] "p2_swap.c"
context p2_swap_global_addresses begin
thm swap'_def
lemma swap_correct:
  "\<lbrakk>IS_VALID(32 word) s (ptr_coerce a); heap_w32 s (ptr_coerce a) = x;
    IS_VALID(32 word) s (ptr_coerce b); heap_w32 s (ptr_coerce b) = y\<rbrakk> \<Longrightarrow>
    swap' a b \<bullet> s \<lbrace> \<lambda>Res _ s. heap_w32 s (ptr_coerce a) = y \<and>
      heap_w32 s (ptr_coerce b) = x \<rbrace>"
  unfolding swap'_def
  by (runs_to_vcg; clarsimp simp: fun_upd_apply)
ML \<open>val _ = if null (Thm_Deps.all_oracles [@{thm swap_correct}]) then
  writeln "AUDIT: swap_correct has no oracle dependencies" else error "Oracle dependency detected"\<close>
end
end
