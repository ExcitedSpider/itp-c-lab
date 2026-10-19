From caesium Require Export notation.
From caesium Require Import tactics.
From refinedc.typing Require Import annotations.
Set Default Proof Using "Type".

(* Generated from [p3_sum_broken.c]. *)
Section code.
  Definition file_0 : string := "/home/opam/.opam/4.14/lib/refinedc/include/refinedc.h".
  Definition file_1 : string := "p3_sum_broken.c".
  Definition loc_2 : location_info := LocationInfo file_0 89 2 89 47.
  Definition loc_3 : location_info := LocationInfo file_0 89 9 89 46.
  Definition loc_4 : location_info := LocationInfo file_0 89 9 89 32.
  Definition loc_5 : location_info := LocationInfo file_0 89 33 89 37.
  Definition loc_6 : location_info := LocationInfo file_0 89 33 89 37.
  Definition loc_7 : location_info := LocationInfo file_0 89 39 89 45.
  Definition loc_8 : location_info := LocationInfo file_0 89 39 89 45.
  Definition loc_11 : location_info := LocationInfo file_1 108 2 108 12.
  Definition loc_12 : location_info := LocationInfo file_1 109 2 109 12.
  Definition loc_13 : location_info := LocationInfo file_1 113 2 116 3.
  Definition loc_14 : location_info := LocationInfo file_1 117 2 117 11.
  Definition loc_15 : location_info := LocationInfo file_1 117 9 117 10.
  Definition loc_16 : location_info := LocationInfo file_1 117 9 117 10.
  Definition loc_17 : location_info := LocationInfo file_1 113 16 116 3.
  Definition loc_18 : location_info := LocationInfo file_1 114 4 114 14.
  Definition loc_19 : location_info := LocationInfo file_1 115 4 115 8.
  Definition loc_20 : location_info := LocationInfo file_1 115 4 115 5.
  Definition loc_21 : location_info := LocationInfo file_1 114 4 114 5.
  Definition loc_22 : location_info := LocationInfo file_1 114 4 114 14.
  Definition loc_23 : location_info := LocationInfo file_1 114 4 114 14.
  Definition loc_24 : location_info := LocationInfo file_1 114 4 114 5.
  Definition loc_25 : location_info := LocationInfo file_1 114 9 114 13.
  Definition loc_26 : location_info := LocationInfo file_1 114 9 114 13.
  Definition loc_27 : location_info := LocationInfo file_1 114 9 114 13.
  Definition loc_28 : location_info := LocationInfo file_1 114 9 114 10.
  Definition loc_29 : location_info := LocationInfo file_1 114 9 114 10.
  Definition loc_30 : location_info := LocationInfo file_1 114 11 114 12.
  Definition loc_31 : location_info := LocationInfo file_1 114 11 114 12.
  Definition loc_32 : location_info := LocationInfo file_1 113 9 113 14.
  Definition loc_33 : location_info := LocationInfo file_1 113 9 113 10.
  Definition loc_34 : location_info := LocationInfo file_1 113 9 113 10.
  Definition loc_35 : location_info := LocationInfo file_1 113 13 113 14.
  Definition loc_36 : location_info := LocationInfo file_1 113 13 113 14.
  Definition loc_37 : location_info := LocationInfo file_1 109 10 109 11.
  Definition loc_40 : location_info := LocationInfo file_1 108 10 108 11.

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

  (* Definition of function [sum_array]. *)
  Definition impl_sum_array : function := {|
    f_args := [
      ("a", void*);
      ("n", it_layout i32)
    ];
    f_local_vars := [
      ("i", it_layout i32);
      ("s", it_layout i32)
    ];
    f_init := "#0";
    f_code := (
      <[ "#0" :=
        "s" <-{ IntOp i32 } LocInfoE loc_40 (i2v 0 i32) ;
        "i" <-{ IntOp i32 } LocInfoE loc_37 (i2v 0 i32) ;
        locinfo: loc_13 ;
        Goto "#1"
      ]> $
      <[ "#1" :=
        locinfo: loc_32 ;
        if{IntOp i32, None}: LocInfoE loc_32 ((LocInfoE loc_33 (use{IntOp i32} (LocInfoE loc_34 ("i")))) <{IntOp i32, IntOp i32, i32} (LocInfoE loc_35 (use{IntOp i32} (LocInfoE loc_36 ("n")))))
        then
        locinfo: loc_18 ;
          Goto "#2"
        else
        locinfo: loc_14 ;
          Goto "#3"
      ]> $
      <[ "#2" :=
        locinfo: loc_18 ;
        LocInfoE loc_21 ("s") <-{ IntOp i32 }
          LocInfoE loc_22 ((LocInfoE loc_23 (use{IntOp i32} (LocInfoE loc_24 ("s")))) +{IntOp i32, IntOp i32} (LocInfoE loc_25 (use{IntOp i32} (LocInfoE loc_27 ((LocInfoE loc_28 (!{PtrOp} (LocInfoE loc_29 ("a")))) at_offset{it_layout i32, PtrOp, IntOp i32} (LocInfoE loc_30 (use{IntOp i32} (LocInfoE loc_31 ("i"))))))))) ;
        locinfo: loc_19 ;
        LocInfoE loc_20 ("i") <-{ IntOp i32 }
          LocInfoE loc_19 ((LocInfoE loc_19 (use{IntOp i32} (LocInfoE loc_20 ("i")))) +{IntOp i32, IntOp i32} (LocInfoE loc_19 (i2v 1 i32))) ;
        locinfo: loc_13 ;
        Goto "#1"
      ]> $
      <[ "#3" :=
        locinfo: loc_14 ;
        Return (LocInfoE loc_15 (use{IntOp i32} (LocInfoE loc_16 ("s"))))
      ]> $∅
    )%E
  |}.
End code.
