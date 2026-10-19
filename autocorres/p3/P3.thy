theory P3
imports "AutoCorres2.AutoCorres"
begin
install_C_file "p3_sum.c"
autocorres [ts_rules = nondet] "p3_sum.c"
context p3_sum_global_addresses begin
thm sum_array'_def
definition array_values :: "lifted_globals \<Rightarrow> 32 signed word ptr \<Rightarrow> int list \<Rightarrow> bool" where
  "array_values s a xs = (\<forall>i<length xs.
    ptr_valid (heap_typing s) (ptr_coerce (a +\<^sub>p int i)::32 word ptr) \<and>
    sint (heap_w32 s (ptr_coerce (a +\<^sub>p int i))) = xs ! i)"
lemma sum_array_correct:
  assumes A: "array_values s a xs"
    and N: "n = int (length xs)" "n \<le> INT_MAX"
    and B: "\<forall>k\<le>length xs. INT_MIN \<le> sum_list (take k xs) \<and> sum_list (take k xs) \<le> INT_MAX"
  shows "sum_array' a n \<bullet> s \<lbrace>\<lambda>Res r s'. r = sum_list xs \<and> s' = s\<rbrace>"
proof -
  have access: "\<And>i. 0 \<le> i \<Longrightarrow> i < n \<Longrightarrow>
    ptr_valid (heap_typing s) (ptr_coerce (a +\<^sub>p i)::32 word ptr) \<and>
    sint (heap_w32 s (ptr_coerce (a +\<^sub>p i))) = xs ! nat i"
  proof -
    fix i::int assume I: "0 \<le> i" "i < n"
    have "nat i < length xs" using I N by linarith
    with A have "ptr_valid (heap_typing s) (ptr_coerce (a +\<^sub>p int (nat i))::32 word ptr) \<and>
      sint (heap_w32 s (ptr_coerce (a +\<^sub>p int (nat i)))) = xs ! nat i"
      unfolding array_values_def by blast
    then show "ptr_valid (heap_typing s) (ptr_coerce (a +\<^sub>p i)::32 word ptr) \<and>
      sint (heap_w32 s (ptr_coerce (a +\<^sub>p i))) = xs ! nat i" using I by simp
  qed
  have step: "\<And>i. 0 \<le> i \<Longrightarrow> i < n \<Longrightarrow>
    sum_list (take (nat i) xs) + sint (heap_w32 s (ptr_coerce (a +\<^sub>p i))) =
      sum_list (take (nat (i+1)) xs)"
  proof -
    fix i::int assume I: "0 \<le> i" "i < n"
    have "nat i < length xs" using I N by linarith
    then show "sum_list (take (nat i) xs) + sint (heap_w32 s (ptr_coerce (a +\<^sub>p i))) =
      sum_list (take (nat (i+1)) xs)"
      using access[OF I] I by (simp add: nat_add_distrib take_Suc_conv_app_nth)
  qed
  show ?thesis
  unfolding sum_array'_def
  supply runs_to_whileLoop_res [where
    I="\<lambda>(i,acc) s'. 0 \<le> i \<and> i \<le> n \<and> acc = sum_list (take (nat i) xs) \<and> s' = s" and
    R="measure' (\<lambda>((i,acc),s'). nat (n-i))", runs_to_vcg]
  apply runs_to_vcg
  subgoal using access by blast
  subgoal premises prems for i
  proof -
    have L: "nat (i+1) \<le> length xs" using prems N by linarith
    have "INT_MIN \<le> sum_list (take (nat (i+1)) xs)" using B L by blast
    then show ?thesis using step[of i] prems by (simp add: INT_MIN_def INT_MAX_def)
  qed
  subgoal premises prems for i
  proof -
    have L: "nat (i+1) \<le> length xs" using prems N by linarith
    have "sum_list (take (nat (i+1)) xs) \<le> INT_MAX" using B L by blast
    then show ?thesis using step[of i] prems by simp
  qed
  subgoal by linarith
  subgoal using N by linarith
  subgoal by linarith
  subgoal by linarith
  subgoal using step by blast
  subgoal using N by auto
  subgoal using N by simp
  done
qed
ML \<open>val _ = if null (Thm_Deps.all_oracles [@{thm sum_array_correct}]) then
  writeln "AUDIT: sum_array_correct has no oracle dependencies" else error "Oracle dependency detected"\<close>
end
end
