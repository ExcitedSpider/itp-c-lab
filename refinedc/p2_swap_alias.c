#include <refinedc.h>
[[rc::parameters("p : loc", "x : Z")]]
[[rc::args("p @ &own<x @ int<i32>>", "p @ &own<place<p>>")]]
[[rc::returns("void")]]
[[rc::ensures("own p : x @ int<i32>")]]
void swap(int *a, int *b) {
  int t = *a;
  *a = *b;
  *b = t;
}
