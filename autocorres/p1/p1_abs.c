/* The limits.h include is omitted: it is used only by the ACSL comment
   in programs/p1_abs.c, and AutoCorres2's restricted preprocessor omits it. */
int abs_val(int x) {
    if (x < 0) return -x;
    return x;
}
