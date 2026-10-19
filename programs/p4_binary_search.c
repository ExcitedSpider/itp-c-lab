/*@ requires 0 <= n;
    requires n > 0 ==> \valid_read(a + (0 .. n-1));
    requires n > 0 ==> \initialized(a + (0 .. n-1));
    requires \forall integer i,j; 0 <= i <= j < n ==> a[i] <= a[j];
    assigns \nothing;
    ensures -1 <= \result < n;
    ensures \result >= 0 ==> a[\result] == key;
    ensures \result == -1 <==> (\forall integer i; 0 <= i < n ==> a[i] != key);
*/
int binary_search(const int *a, int n, int key) {
    int lo = 0;
    int hi = n;
    /*@ loop invariant 0 <= lo <= hi <= n;
        loop invariant \forall integer i; 0 <= i < lo ==> a[i] < key;
        loop invariant \forall integer i; hi <= i < n ==> a[i] > key;
        loop assigns lo, hi;
        loop variant hi-lo;
    */
    while (lo < hi) {
        int mid = lo + (hi-lo)/2;
        if (a[mid] == key) return mid;
        if (a[mid] < key) lo = mid+1;
        else hi = mid;
    }
    return -1;
}
