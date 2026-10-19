/*@ requires \valid_read(a) && \initialized(a);
    assigns \nothing;
    ensures \result == *a;
*/
int read_int(int *a) { return *a; }
