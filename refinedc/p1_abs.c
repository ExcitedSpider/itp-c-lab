#include <refinedc.h>
#include <limits.h>

[[rc::parameters("x : Z")]]
[[rc::args("x @ int<i32>")]]
[[rc::requires("{min_int i32 < x}")]]
[[rc::returns("{Z.abs x} @ int<i32>")]]
int abs_val(int x) {
    if (x < 0) return -x;
    return x;
}
