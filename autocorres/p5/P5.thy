(* Adapted from AFP AutoCorres2/tests/examples/ListRev.thy.
 * Copyright 2020 Data61, CSIRO; Copyright 2022 Apple Inc.
 * SPDX-License-Identifier: BSD-2-Clause *)
theory P5
imports "AutoCorres2.AutoCorres"
begin
install_C_file "../../programs/p5_reverse.c"
autocorres [heap_abs_syntax] "p5_reverse.c"
context p5_reverse_global_addresses begin
primrec listrep :: "lifted_globals \<Rightarrow> node_C ptr \<Rightarrow> node_C ptr list \<Rightarrow> bool" where
  "listrep s p [] = (p = NULL)"
| "listrep s p (x#xs) = (p = x \<and> p \<noteq> NULL \<and>
     ptr_valid (heap_typing s) p \<and> listrep s (s[p]\<rightarrow>next) xs)"
lemma list_empty [simp]: "listrep s NULL xs = (xs = [])"
  by (induct xs) auto
lemma list_in [simp]: "\<lbrakk>listrep s p xs; p \<noteq> NULL\<rbrakk> \<Longrightarrow> p \<in> set xs"
  by (induct xs) auto
lemma list_non_NULL:
  "p \<noteq> NULL \<Longrightarrow> listrep s p xs =
    (\<exists>ys. xs = p#ys \<and> ptr_valid (heap_typing s) p \<and> listrep s (s[p]\<rightarrow>next) ys)"
  by (cases xs) auto
lemma list_unique: "listrep s p xs \<Longrightarrow> listrep s p ys \<Longrightarrow> xs = ys"
  by (induct xs arbitrary: p ys) (auto simp: list_non_NULL)
lemma list_append_Ex: "listrep s p (xs @ ys) \<Longrightarrow> (\<exists>q. listrep s q ys)"
  by (induct xs arbitrary: p) auto
lemma list_distinct [simp]: "listrep s p xs \<Longrightarrow> distinct xs"
  apply (induct xs arbitrary: p)
   apply simp
  apply (clarsimp dest!: split_list)
  apply (frule list_append_Ex)
  apply (auto dest: list_unique)
  done
lemma list_heap_update_ignore [simp]:
  "q \<notin> set xs \<Longrightarrow> listrep (s[q\<rightarrow>next := v]) p xs = listrep s p xs"
  by (induct xs arbitrary: p) (auto simp: fun_upd_def)
definition "the_list s p = (THE xs. listrep s p xs)"
lemma the_list_val [simp]: "listrep s p xs \<Longrightarrow> the_list s p = xs"
  unfolding the_list_def by (metis list_unique the_equality)
lemma the_list_update [simp]:
  "\<lbrakk>q \<notin> set xs; listrep s p xs\<rbrakk> \<Longrightarrow>
     the_list s[q\<rightarrow>next := v] p = the_list s p"
  by (metis list_heap_update_ignore the_list_val)
definition "reverse_inv xs s0 l r s =
  (\<exists>ys zs. listrep s l ys \<and> listrep s r zs \<and>
    rev xs = rev ys @ zs \<and> distinct (rev xs) \<and>
    (\<forall>p \<in> set xs. s[p]\<rightarrow>value = s0[p]\<rightarrow>value))"
lemmas runs_to_whileLoop2 = runs_to_whileLoop_res' [split_tuple C and B arity: 2]
lemma reverse_correct:
  "listrep s p xs \<Longrightarrow> reverse' p \<bullet> s
    \<lbrace>\<lambda>Res r s'. listrep s' r (rev xs) \<and>
      (\<forall>p \<in> set xs. s'[p]\<rightarrow>value = s[p]\<rightarrow>value)\<rbrace>"
  unfolding reverse'_def
  apply runs_to_vcg
  apply (rule runs_to_whileLoop2 [where
    I="\<lambda>(l,r) s'. reverse_inv xs s l r s'" and
    R="measure (\<lambda>((l,r),s). length (the_list s l))",
    unfolded reverse_inv_def])
  subgoal by simp
  subgoal by simp
  subgoal by (simp split: prod.splits)
  supply distinct_rev[simp del]
  apply runs_to_vcg
  subgoal using list_non_NULL by blast
  subgoal for p_ys p_zs s1 ys zs
    apply (case_tac ys, fastforce)
    apply clarsimp
    subgoal for ys'
      apply (rule_tac x=ys' in exI)
      apply (simp add: fun_upd_def)
      done
    done
  subgoal for p_ys p_zs s1 ys zs
    apply (case_tac ys, fastforce)
    apply clarsimp
    subgoal for ys'
      apply (subgoal_tac "the_list s1 p_ys = (p_ys#ys')")
       apply (simp only:)
       apply simp
      apply simp
      done
    done
  done
ML \<open>val _ = if null (Thm_Deps.all_oracles [@{thm reverse_correct}]) then
  writeln "AUDIT: reverse_correct has no oracle dependencies" else error "Oracle dependency detected"\<close>
end
end
