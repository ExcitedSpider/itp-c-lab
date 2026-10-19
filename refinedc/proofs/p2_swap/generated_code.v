From caesium Require Export notation.
From caesium Require Import tactics.
From refinedc.typing Require Import annotations.
Set Default Proof Using "Type".

(* Generated from [p2_swap.c]. *)
Section code.
  Definition file_0 : string := "/home/opam/.opam/4.14/lib/refinedc/include/refinedc.h".
  Definition file_1 : string := "p2_swap.c".
  Definition loc_2 : location_info := LocationInfo file_0 89 2 89 47.
  Definition loc_3 : location_info := LocationInfo file_0 89 9 89 46.
  Definition loc_4 : location_info := LocationInfo file_0 89 9 89 32.
  Definition loc_5 : location_info := LocationInfo file_0 89 33 89 37.
  Definition loc_6 : location_info := LocationInfo file_0 89 33 89 37.
  Definition loc_7 : location_info := LocationInfo file_0 89 39 89 45.
  Definition loc_8 : location_info := LocationInfo file_0 89 39 89 45.
  Definition loc_11 : location_info := LocationInfo file_1 102 4 102 15.
  Definition loc_12 : location_info := LocationInfo file_1 103 4 103 12.
  Definition loc_13 : location_info := LocationInfo file_1 104 4 104 11.
  Definition loc_14 : location_info := LocationInfo file_1 104 4 104 6.
  Definition loc_15 : location_info := LocationInfo file_1 104 5 104 6.
  Definition loc_16 : location_info := LocationInfo file_1 104 5 104 6.
  Definition loc_17 : location_info := LocationInfo file_1 104 9 104 10.
  Definition loc_18 : location_info := LocationInfo file_1 104 9 104 10.
  Definition loc_19 : location_info := LocationInfo file_1 103 4 103 6.
  Definition loc_20 : location_info := LocationInfo file_1 103 5 103 6.
  Definition loc_21 : location_info := LocationInfo file_1 103 5 103 6.
  Definition loc_22 : location_info := LocationInfo file_1 103 9 103 11.
  Definition loc_23 : location_info := LocationInfo file_1 103 9 103 11.
  Definition loc_24 : location_info := LocationInfo file_1 103 10 103 11.
  Definition loc_25 : location_info := LocationInfo file_1 103 10 103 11.
  Definition loc_26 : location_info := LocationInfo file_1 102 12 102 14.
  Definition loc_27 : location_info := LocationInfo file_1 102 12 102 14.
  Definition loc_28 : location_info := LocationInfo file_1 102 13 102 14.
  Definition loc_29 : location_info := LocationInfo file_1 102 13 102 14.

  (* Definition of function [copy_alloc_id]. *)
  Definition impl_copy_alloc_id : function := {|
    f_args := [
      ("to", it_layout uintptr_t);
      ("from", void*)
    ];
    f_local_vars := [
    ];
    f_init := "#0";
    f_code := (
      <[ "#0" :=
        locinfo: loc_2 ;
        Return (LocInfoE loc_3 (CopyAllocId (IntOp uintptr_t) (LocInfoE loc_5 (use{IntOp uintptr_t} (LocInfoE loc_6 ("to")))) (LocInfoE loc_7 (use{PtrOp} (LocInfoE loc_8 ("from"))))))
      ]> $∅
    )%E
  |}.

  (* Definition of function [swap]. *)
  Definition impl_swap : function := {|
    f_args := [
      ("a", void*);
      ("b", void*)
    ];
    f_local_vars := [
      ("t", it_layout i32)
    ];
    f_init := "#0";
    f_code := (
      <[ "#0" :=
        "t" <-{ IntOp i32 }
          LocInfoE loc_26 (use{IntOp i32} (LocInfoE loc_28 (!{PtrOp} (LocInfoE loc_29 ("a"))))) ;
        locinfo: loc_12 ;
        LocInfoE loc_20 (!{PtrOp} (LocInfoE loc_21 ("a"))) <-{ IntOp i32 }
          LocInfoE loc_22 (use{IntOp i32} (LocInfoE loc_24 (!{PtrOp} (LocInfoE loc_25 ("b"))))) ;
        locinfo: loc_13 ;
        LocInfoE loc_15 (!{PtrOp} (LocInfoE loc_16 ("b"))) <-{ IntOp i32 }
          LocInfoE loc_17 (use{IntOp i32} (LocInfoE loc_18 ("t"))) ;
        Return (VOID)
      ]> $∅
    )%E
  |}.
End code.
