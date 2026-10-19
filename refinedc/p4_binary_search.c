#include <refinedc.h>

[[rc::parameters("p : loc", "xs : {list Z}", "n : nat", "key : Z")]]
[[rc::args("p @ &own<array<i32, {xs `at_type` int i32}>>", "n @ int<i32>", "key @ int<i32>")]]
[[rc::requires("{n = length xs}",
  "{∀ i j x y, (i ≤ j)%nat → xs !! i = Some x → xs !! j = Some y → x ≤ y}")]]
[[rc::exists("res : Z")]]
[[rc::returns("res @ int<i32>")]]
[[rc::ensures("{(-1 ≤ res < n)%Z}",
  "{0 ≤ res → xs !! Z.to_nat res = Some key}",
  "{res = -1 ↔ ∀ i, xs !! i ≠ Some key}",
  "own p : array<i32, {xs `at_type` int i32}>")]]
[[rc::tactics("all: try by split; [intro; exfalso; solve_goal | intro Hnone; exfalso; apply (Hnone _ H14)].")]]
[[rc::tactics("all: try by have Hxy : x ≤ y := H i (Z.to_nat (vl + (vh-vl) `quot` 2)) x y ltac:(solve_goal) H25 H14; lia.")]]
[[rc::tactics("all: try by have Hyx : y ≤ x := H (Z.to_nat (vl + (vh-vl) `quot` 2)) i y x H22 H14 H23; lia.")]]
[[rc::tactics("all: try by split; [intros _ i Hi; destruct (decide (i < vl)%nat) as [Hil|Hil]; [pose proof (H2 i key Hil Hi); lia | pose proof (H3 i key ltac:(lia) Hi); lia] | done].")]]
int binary_search(const int *a, int n, int key) {
  int lo = 0;
  int hi = n;
  [[rc::exists("vl : nat", "vh : nat")]]
  [[rc::inv_vars("lo : vl @ int<i32>", "hi : vh @ int<i32>")]]
  [[rc::constraints("{(vl ≤ vh ≤ n)%nat}",
    "{∀ i x, (i < vl)%nat → xs !! i = Some x → x < key}",
    "{∀ i x, (vh ≤ i)%nat → xs !! i = Some x → key < x}")]]
  while (lo < hi) {
    int mid = lo + (hi - lo) / 2;
    if (a[mid] == key) return mid;
    if (a[mid] < key) lo = mid + 1;
    else hi = mid;
  }
  return -1;
}
