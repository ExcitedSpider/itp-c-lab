#include <refinedc.h>

typedef struct [[rc::refined_by("xs : {list Z}")]]
  [[rc::typedef("node_t : {maybe2 cons xs} @ optionalO<λ (x, xs). &own<...>>")]] node {
  [[rc::field("x @ int<i32>")]]
  int value;
  [[rc::field("xs @ node_t")]]
  struct node *next;
} *node_t;

[[rc::parameters("xs : {list Z}")]]
[[rc::args("xs @ node_t")]]
[[rc::returns("{rev xs} @ node_t")]]
struct node *reverse(struct node *l) {
  struct node *r = 0;
  [[rc::exists("ys : {list Z}", "zs : {list Z}")]]
  [[rc::inv_vars("r : ys @ node_t", "l : zs @ node_t")]]
  [[rc::constraints("{xs = rev ys ++ zs}")]]
  while (l != 0) {
    struct node *next = l->next;
    l->next = r;
    r = l;
    l = next;
  }
  return r;
}
