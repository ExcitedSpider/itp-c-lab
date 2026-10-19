From caesium Require Export notation.
From caesium Require Import tactics.
From refinedc.typing Require Import annotations.
Set Default Proof Using "Type".

(* Generated from [p1_abs.c]. *)
Section code.
  Definition file_0 : string := "/home/opam/.opam/4.14/lib/refinedc/include/refinedc.h".
  Definition file_1 : string := "p1_abs.c".
  Definition loc_2 : location_info := LocationInfo file_0 89 2 89 47.
  Definition loc_3 : location_info := LocationInfo file_0 89 9 89 46.
  Definition loc_4 : location_info := LocationInfo file_0 89 9 89 32.
  Definition loc_5 : location_info := LocationInfo file_0 89 33 89 37.
  Definition loc_6 : location_info := LocationInfo file_0 89 33 89 37.
  Definition loc_7 : location_info := LocationInfo file_0 89 39 89 45.
  Definition loc_8 : location_info := LocationInfo file_0 89 39 89 45.
  Definition loc_11 : location_info := LocationInfo file_1 103 4 103 25.
  Definition loc_12 : location_info := LocationInfo file_1 104 4 104 13.
  Definition loc_13 : location_info := LocationInfo file_1 104 11 104 12.
  Definition loc_14 : location_info := LocationInfo file_1 104 11 104 12.
  Definition loc_15 : location_info := LocationInfo file_1 103 15 103 25.
  Definition loc_16 : location_info := LocationInfo file_1 103 22 103 24.
  Definition loc_17 : location_info := LocationInfo file_1 103 23 103 24.
  Definition loc_18 : location_info := LocationInfo file_1 103 23 103 24.
  Definition loc_19 : location_info := LocationInfo file_1 103 4 103 25.
  Definition loc_20 : location_info := LocationInfo file_1 103 8 103 13.
  Definition loc_21 : location_info := LocationInfo file_1 103 8 103 9.
  Definition loc_22 : location_info := LocationInfo file_1 103 8 103 9.
  Definition loc_23 : location_info := LocationInfo file_1 103 12 103 13.

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

  (* Definition of function [abs_val]. *)
  Definition impl_abs_val : function := {|
    f_args := [
      ("x", it_layout i32)
    ];
    f_local_vars := [
    ];
    f_init := "#0";
    f_code := (
      <[ "#0" :=
        locinfo: loc_20 ;
        if{IntOp i32, Some "#1"}: LocInfoE loc_20 ((LocInfoE loc_21 (use{IntOp i32} (LocInfoE loc_22 ("x")))) <{IntOp i32, IntOp i32, i32} (LocInfoE loc_23 (i2v 0 i32)))
        then
        locinfo: loc_15 ;
          Goto "#2"
        else
        locinfo: loc_12 ;
          Goto "#3"
      ]> $
      <[ "#1" :=
        locinfo: loc_12 ;
        Return (LocInfoE loc_13 (use{IntOp i32} (LocInfoE loc_14 ("x"))))
      ]> $
      <[ "#2" :=
        locinfo: loc_15 ;
        Return (LocInfoE loc_16 (UnOp NegOp (IntOp i32) (LocInfoE loc_17 (use{IntOp i32} (LocInfoE loc_18 ("x"))))))
      ]> $
      <[ "#3" :=
        locinfo: loc_12 ;
        Goto "#1"
      ]> $∅
    )%E
  |}.
End code.
