#include <refinedc.h>

[[rc::parameters("p : loc", "q : loc", "x : Z", "y : Z")]]
[[rc::args("p @ &own<x @ int<i32>>", "q @ &own<y @ int<i32>>")]]
[[rc::returns("void")]]
[[rc::ensures("own p : y @ int<i32>", "own q : x @ int<i32>")]]
void swap(int *a, int *b) {
    int t = *a;
    *a = *b;
    *b = t;
}
