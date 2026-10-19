theory P4
imports "AutoCorres2.AutoCorres"
begin
install_C_file "../../programs/p4_binary_search.c"
autocorres [ts_rules = nondet] "p4_binary_search.c"
context p4_binary_search_global_addresses begin
lemma mid_bounds:
  fixes lo hi :: int
  assumes "0 \<le> lo" "lo < hi"
  shows "lo \<le> lo + (hi-lo) sdiv 2 \<and> lo + (hi-lo) sdiv 2 < hi"
  using assms by (simp add: signed_divide_int_def sgn_if; presburger)
definition array_values :: "lifted_globals \<Rightarrow> 32 signed word ptr \<Rightarrow> int list \<Rightarrow> bool" where
  "array_values s a xs = (\<forall>i<length xs.
    ptr_valid (heap_typing s) (ptr_coerce (a +\<^sub>p int i)::32 word ptr) \<and>
    sint (heap_w32 s (ptr_coerce (a +\<^sub>p int i))) = xs ! i)"
lemma binary_search_correct:
  assumes A: "array_values s a xs"
    and N: "n = int (length xs)" "n \<le> INT_MAX"
    and K: "INT_MIN \<le> key" "key \<le> INT_MAX"
    and S: "\<forall>i j. i \<le> j \<and> j < length xs \<longrightarrow> xs!i \<le> xs!j"
  shows "binary_search' a n key \<bullet> s \<lbrace>\<lambda>Res r s'.
    -1 \<le> r \<and> r < n \<and> (0 \<le> r \<longrightarrow> xs ! nat r = key) \<and>
    (r = -1 \<longleftrightarrow> key \<notin> set xs) \<and> s' = s\<rbrace>"
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
  show ?thesis
  unfolding binary_search'_def
  supply runs_to_whileLoop_exn' [where
    I="\<lambda>r s'. case r of Result (hi,lo) \<Rightarrow>
      (0 \<le> lo \<and> lo \<le> hi \<and> hi \<le> n \<and> s' = s \<and>
      (\<forall>i<nat lo. xs!i < key) \<and> (\<forall>i. nat hi \<le> i \<and> i < length xs \<longrightarrow> key < xs!i))
      | Exn k \<Rightarrow> (0 \<le> k \<and> k < n \<and> xs!nat k = key \<and> s' = s)" and
    R="measure' (\<lambda>((hi,lo),s'). nat (hi-lo))", runs_to_vcg]
  apply runs_to_vcg
  apply (insert N K S access)
  apply (auto simp: INT_MIN_def INT_MAX_def signed_divide_int_def sgn_if)
  subgoal premises prems for hi lo
  proof -
    let ?m = "lo + (hi-lo) div 2"
    have M: "0 \<le> ?m" "?m < n" using prems by presburger+
    have R: "sint (heap_w32 s (ptr_coerce (a +\<^sub>p ?m))) = xs ! nat ?m"
      using access[OF M] by blast
    have W: "sint (word_of_int key::32 word) = key"
      using K by (simp add: sint_of_int_eq INT_MIN_def INT_MAX_def)
    show ?thesis using R W prems by auto
  qed
  subgoal premises prems for hi lo i
  proof -
    let ?m = "lo + (hi-lo) div 2"
    have MB: "lo \<le> ?m \<and> ?m < hi"
      using mid_bounds[of lo hi] prems by (simp add: signed_divide_int_def sgn_if)
    have M0: "0 \<le> ?m" using MB prems by linarith
    have M1: "nat ?m < length xs" using MB M0 prems by linarith
    have E: "nat (?m+1) = Suc (nat ?m)" using M0 by (simp add: nat_add_distrib)
    have M2: "i \<le> nat ?m" using E prems by linarith
    have "xs!i \<le> xs!nat ?m" using S M1 M2 by blast
    then show ?thesis using prems by linarith
  qed
  subgoal premises prems for hi lo i
  proof -
    let ?m = "lo + (hi-lo) div 2"
    have MB: "lo \<le> ?m \<and> ?m < hi"
      using mid_bounds[of lo hi] prems by (simp add: signed_divide_int_def sgn_if)
    have M: "0 \<le> ?m" "?m < n" using MB prems by linarith+
    have R: "sint (heap_w32 s (ptr_coerce (a +\<^sub>p ?m))) = xs ! nat ?m"
      using access[OF M] by blast
    have NE: "xs ! nat ?m \<noteq> key" using R prems by (metis of_int_sint)
    have "xs!nat ?m \<le> xs!i" using S prems by blast
    then show ?thesis using NE prems by linarith
  qed
  subgoal premises prems for hi
  proof -
    obtain i where I: "i < length xs" "xs!i = key" using prems by (auto simp: in_set_conv_nth)
    show False
    proof (cases "i < nat hi")
      case True
      have "xs!i < key" using prems True by blast
      then show False using I by simp
    next
      case False
      have "nat hi \<le> i" using False by simp
      then have "key < xs!i" using prems I by blast
      then show False using I by simp
    qed
  qed
  done
qed
ML \<open>val _ = if null (Thm_Deps.all_oracles [@{thm binary_search_correct}]) then
  writeln "AUDIT: binary_search_correct has no oracle dependencies" else error "Oracle dependency detected"\<close>
end
end
