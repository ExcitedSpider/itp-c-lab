#include <limits.h>

/*@ requires x > INT_MIN;
    assigns \nothing;
    ensures \result == (x < 0 ? - (integer)x : x);
*/
int abs_val(int x) {
    if (x < 0) return -x;
    return x;
}
