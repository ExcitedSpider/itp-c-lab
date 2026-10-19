/*@ requires \valid(a) && \valid(b);
    requires \initialized(a) && \initialized(b);
    assigns *a, *b;
    ensures *a == \old(*b);
    ensures *b == \old(*a);
*/
void swap(int *a, int *b) {
    int t = *a;
    *a = *b;
    *b = t;
}
