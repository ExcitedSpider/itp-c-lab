struct node { int value; struct node *next; };

/*@ logic struct node *nth{L}(struct node *p, integer i) =
      i <= 0 ? p : nth(p->next, i-1);
    inductive list{L}(struct node *p, integer n) {
      case empty{L}: list(\null,0);
      case cons{L}: \forall struct node *p, integer n;
        n >= 0 && \valid(p) && \initialized(p) && list(p->next,n) &&
        (\forall integer i; 0 <= i < n ==> \separated(p,nth(p->next,i)))
        ==> list(p,n+1);
    }
*/
/*@ requires \exists integer n; n >= 0 && list(l,n);
    assigns { p->next | struct node *p; \exists integer n,i;
      list(l,n) && 0 <= i < n && p == nth(l,i) };
    ensures \forall integer n; list{Pre}(\at(l,Pre),n) ==> list(\result,n);
    ensures \forall integer n,i; list{Pre}(\at(l,Pre),n) && 0 <= i < n ==>
      nth(\result,i) == nth{Pre}(\at(l,Pre),n-1-i);
    ensures \forall integer n,i; list{Pre}(\at(l,Pre),n) && 0 <= i < n ==>
      nth(\result,i)->value == \at(nth(l,n-1-i)->value,Pre);
*/
struct node *reverse(struct node *l) {
    struct node *r = 0;
    /*@ loop invariant \exists integer m,k;
          0 <= m && 0 <= k && list(l,m) && list(r,k) &&
          (\forall integer i,j; 0 <= i < m && 0 <= j < k ==>
             \separated(nth(l,i),nth(r,j))) &&
          (\forall integer n; list{Pre}(\at(l,Pre),n) ==>
             n == m+k &&
             (\forall integer i; 0 <= i < m ==>
                nth(l,i) == nth{Pre}(\at(l,Pre),k+i)) &&
             (\forall integer i; 0 <= i < k ==>
                nth(r,i) == nth{Pre}(\at(l,Pre),k-1-i)));
        loop invariant \forall integer n,i;
          list{Pre}(\at(l,Pre),n) && 0 <= i < n ==>
          nth{Pre}(\at(l,Pre),i)->value == \at(nth(l,i)->value,Pre);
        loop assigns l, r, { p->next | struct node *p; \exists integer n,i;
          list{Pre}(\at(l,Pre),n) && 0 <= i < n &&
          p == nth{Pre}(\at(l,Pre),i) };
    */
    while (l != 0) {
        struct node *next = l->next;
        l->next = r;
        r = l;
        l = next;
    }
    return r;
}
