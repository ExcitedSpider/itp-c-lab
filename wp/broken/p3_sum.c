#include <limits.h>

/*@ logic integer prefix_sum{L}(int *a, integer n) =
      n <= 0 ? 0 : prefix_sum(a, n-1) + a[n-1];
*/
/*@ requires 0 <= n;
    requires n > 0 ==> \valid_read(a + (0 .. n-1));
    requires n > 0 ==> \initialized(a + (0 .. n-1));
    requires \forall integer k; 0 <= k <= n ==>
      INT_MIN <= prefix_sum(a,k) <= INT_MAX;
    assigns \nothing;
    ensures \result == prefix_sum(a,n);
*/
int sum_array(const int *a, int n) {
    int s = 0;
    int i = 0;
    /*@ loop invariant 0 <= i <= n;
        loop invariant s == prefix_sum(a,i) + 1;
        loop assigns i, s;
        loop variant n-i;
    */
    while (i < n) {
        /*@ assert prefix_sum(a,i+1) == s + (integer)a[i]; */
        s += a[i];
        i++;
    }
    return s;
}
