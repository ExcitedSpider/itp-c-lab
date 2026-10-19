/* limits.h and ACSL comments omitted; executable body matches programs/p3_sum.c. */
int sum_array(const int *a, int n) {
    int s = 0;
    int i = 0;
    while (i < n) {
        s += a[i];
        i++;
    }
    return s;
}
