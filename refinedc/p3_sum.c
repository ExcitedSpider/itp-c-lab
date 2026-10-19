#include <refinedc.h>
//@rc::import sum_extra from c_itp_refinedc.p3_sum

[[rc::parameters("p : loc", "xs : {list Z}", "n : nat")]]
[[rc::args("p @ &own<array<i32, {xs `at_type` int i32}>>", "n @ int<i32>")]]
[[rc::requires("{n = length xs}",
  "{∀ k, (k ≤ n)%nat → min_int i32 ≤ sumZ (take k xs) ≤ max_int i32}")]]
[[rc::returns("{sumZ xs} @ int<i32>")]]
[[rc::ensures("own p : array<i32, {xs `at_type` int i32}>")]]
[[rc::lemmas("prefix_step")]]
[[rc::tactics("all: try by pose proof (prefix_step xs j y H6); pose proof (H (S j) ltac:(lia)); lia.")]]
[[rc::tactics("all: try by rewrite Nat.add_1_r; symmetry; apply prefix_step.")]]
int sum_array(const int *a, int n) {
  int s = 0;
  int i = 0;
  [[rc::exists("j : nat")]]
  [[rc::inv_vars("i : j @ int<i32>", "s : {sumZ (take j xs)} @ int<i32>")]]
  [[rc::constraints("{(j ≤ n)%nat}")]]
  while (i < n) {
    s += a[i];
    i++;
  }
  return s;
}
