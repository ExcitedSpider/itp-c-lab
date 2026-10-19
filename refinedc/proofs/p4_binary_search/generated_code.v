From caesium Require Export notation.
From caesium Require Import tactics.
From refinedc.typing Require Import annotations.
Set Default Proof Using "Type".

(* Generated from [p4_binary_search.c]. *)
Section code.
  Definition file_0 : string := "/home/opam/.opam/4.14/lib/refinedc/include/refinedc.h".
  Definition file_1 : string := "p4_binary_search.c".
  Definition loc_2 : location_info := LocationInfo file_0 89 2 89 47.
  Definition loc_3 : location_info := LocationInfo file_0 89 9 89 46.
  Definition loc_4 : location_info := LocationInfo file_0 89 9 89 32.
  Definition loc_5 : location_info := LocationInfo file_0 89 33 89 37.
  Definition loc_6 : location_info := LocationInfo file_0 89 33 89 37.
  Definition loc_7 : location_info := LocationInfo file_0 89 39 89 45.
  Definition loc_8 : location_info := LocationInfo file_0 89 39 89 45.
  Definition loc_11 : location_info := LocationInfo file_1 112 2 112 13.
  Definition loc_12 : location_info := LocationInfo file_1 113 2 113 13.
  Definition loc_13 : location_info := LocationInfo file_1 119 2 124 3.
  Definition loc_14 : location_info := LocationInfo file_1 125 2 125 12.
  Definition loc_15 : location_info := LocationInfo file_1 125 9 125 11.
  Definition loc_16 : location_info := LocationInfo file_1 125 10 125 11.
  Definition loc_17 : location_info := LocationInfo file_1 119 18 124 3.
  Definition loc_18 : location_info := LocationInfo file_1 120 4 120 33.
  Definition loc_19 : location_info := LocationInfo file_1 121 4 121 34.
  Definition loc_20 : location_info := LocationInfo file_1 122 4 123 18.
  Definition loc_21 : location_info := LocationInfo file_1 122 22 122 35.
  Definition loc_22 : location_info := LocationInfo file_1 122 22 122 24.
  Definition loc_23 : location_info := LocationInfo file_1 122 27 122 34.
  Definition loc_24 : location_info := LocationInfo file_1 122 27 122 30.
  Definition loc_25 : location_info := LocationInfo file_1 122 27 122 30.
  Definition loc_26 : location_info := LocationInfo file_1 122 33 122 34.
  Definition loc_27 : location_info := LocationInfo file_1 123 9 123 18.
  Definition loc_28 : location_info := LocationInfo file_1 123 9 123 11.
  Definition loc_29 : location_info := LocationInfo file_1 123 14 123 17.
  Definition loc_30 : location_info := LocationInfo file_1 123 14 123 17.
  Definition loc_31 : location_info := LocationInfo file_1 122 8 122 20.
  Definition loc_32 : location_info := LocationInfo file_1 122 8 122 14.
  Definition loc_33 : location_info := LocationInfo file_1 122 8 122 14.
  Definition loc_34 : location_info := LocationInfo file_1 122 8 122 14.
  Definition loc_35 : location_info := LocationInfo file_1 122 8 122 9.
  Definition loc_36 : location_info := LocationInfo file_1 122 8 122 9.
  Definition loc_37 : location_info := LocationInfo file_1 122 10 122 13.
  Definition loc_38 : location_info := LocationInfo file_1 122 10 122 13.
  Definition loc_39 : location_info := LocationInfo file_1 122 17 122 20.
  Definition loc_40 : location_info := LocationInfo file_1 122 17 122 20.
  Definition loc_41 : location_info := LocationInfo file_1 121 23 121 34.
  Definition loc_42 : location_info := LocationInfo file_1 121 30 121 33.
  Definition loc_43 : location_info := LocationInfo file_1 121 30 121 33.
  Definition loc_44 : location_info := LocationInfo file_1 121 4 121 34.
  Definition loc_45 : location_info := LocationInfo file_1 121 8 121 21.
  Definition loc_46 : location_info := LocationInfo file_1 121 8 121 14.
  Definition loc_47 : location_info := LocationInfo file_1 121 8 121 14.
  Definition loc_48 : location_info := LocationInfo file_1 121 8 121 14.
  Definition loc_49 : location_info := LocationInfo file_1 121 8 121 9.
  Definition loc_50 : location_info := LocationInfo file_1 121 8 121 9.
  Definition loc_51 : location_info := LocationInfo file_1 121 10 121 13.
  Definition loc_52 : location_info := LocationInfo file_1 121 10 121 13.
  Definition loc_53 : location_info := LocationInfo file_1 121 18 121 21.
  Definition loc_54 : location_info := LocationInfo file_1 121 18 121 21.
  Definition loc_55 : location_info := LocationInfo file_1 120 14 120 32.
  Definition loc_56 : location_info := LocationInfo file_1 120 14 120 16.
  Definition loc_57 : location_info := LocationInfo file_1 120 14 120 16.
  Definition loc_58 : location_info := LocationInfo file_1 120 19 120 32.
  Definition loc_59 : location_info := LocationInfo file_1 120 19 120 28.
  Definition loc_60 : location_info := LocationInfo file_1 120 20 120 22.
  Definition loc_61 : location_info := LocationInfo file_1 120 20 120 22.
  Definition loc_62 : location_info := LocationInfo file_1 120 25 120 27.
  Definition loc_63 : location_info := LocationInfo file_1 120 25 120 27.
  Definition loc_64 : location_info := LocationInfo file_1 120 31 120 32.
  Definition loc_67 : location_info := LocationInfo file_1 119 9 119 16.
  Definition loc_68 : location_info := LocationInfo file_1 119 9 119 11.
  Definition loc_69 : location_info := LocationInfo file_1 119 9 119 11.
  Definition loc_70 : location_info := LocationInfo file_1 119 14 119 16.
  Definition loc_71 : location_info := LocationInfo file_1 119 14 119 16.
  Definition loc_72 : location_info := LocationInfo file_1 113 11 113 12.
  Definition loc_73 : location_info := LocationInfo file_1 113 11 113 12.
  Definition loc_76 : location_info := LocationInfo file_1 112 11 112 12.

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

  (* Definition of function [binary_search]. *)
  Definition impl_binary_search : function := {|
    f_args := [
      ("a", void*);
      ("n", it_layout i32);
      ("key", it_layout i32)
    ];
    f_local_vars := [
      ("lo", it_layout i32);
      ("mid", it_layout i32);
      ("hi", it_layout i32)
    ];
    f_init := "#0";
    f_code := (
      <[ "#0" :=
        "lo" <-{ IntOp i32 } LocInfoE loc_76 (i2v 0 i32) ;
        "hi" <-{ IntOp i32 }
          LocInfoE loc_72 (use{IntOp i32} (LocInfoE loc_73 ("n"))) ;
        locinfo: loc_13 ;
        Goto "#1"
      ]> $
      <[ "#1" :=
        locinfo: loc_67 ;
        if{IntOp i32, None}: LocInfoE loc_67 ((LocInfoE loc_68 (use{IntOp i32} (LocInfoE loc_69 ("lo")))) <{IntOp i32, IntOp i32, i32} (LocInfoE loc_70 (use{IntOp i32} (LocInfoE loc_71 ("hi")))))
        then
        Goto "#2"
        else
        locinfo: loc_14 ;
          Goto "#3"
      ]> $
      <[ "#2" :=
        "mid" <-{ IntOp i32 }
          LocInfoE loc_55 ((LocInfoE loc_56 (use{IntOp i32} (LocInfoE loc_57 ("lo")))) +{IntOp i32, IntOp i32} (LocInfoE loc_58 ((LocInfoE loc_59 ((LocInfoE loc_60 (use{IntOp i32} (LocInfoE loc_61 ("hi")))) -{IntOp i32, IntOp i32} (LocInfoE loc_62 (use{IntOp i32} (LocInfoE loc_63 ("lo")))))) /{IntOp i32, IntOp i32} (LocInfoE loc_64 (i2v 2 i32))))) ;
        locinfo: loc_45 ;
        if{IntOp i32, Some "#4"}: LocInfoE loc_45 ((LocInfoE loc_46 (use{IntOp i32} (LocInfoE loc_48 ((LocInfoE loc_49 (!{PtrOp} (LocInfoE loc_50 ("a")))) at_offset{it_layout i32, PtrOp, IntOp i32} (LocInfoE loc_51 (use{IntOp i32} (LocInfoE loc_52 ("mid")))))))) ={IntOp i32, IntOp i32, i32} (LocInfoE loc_53 (use{IntOp i32} (LocInfoE loc_54 ("key")))))
        then
        locinfo: loc_41 ;
          Goto "#7"
        else
        locinfo: loc_31 ;
          Goto "#8"
      ]> $
      <[ "#3" :=
        locinfo: loc_14 ;
        Return (LocInfoE loc_15 (UnOp NegOp (IntOp i32) (LocInfoE loc_16 (i2v 1 i32))))
      ]> $
      <[ "#4" :=
        locinfo: loc_31 ;
        if{IntOp i32, None}: LocInfoE loc_31 ((LocInfoE loc_32 (use{IntOp i32} (LocInfoE loc_34 ((LocInfoE loc_35 (!{PtrOp} (LocInfoE loc_36 ("a")))) at_offset{it_layout i32, PtrOp, IntOp i32} (LocInfoE loc_37 (use{IntOp i32} (LocInfoE loc_38 ("mid")))))))) <{IntOp i32, IntOp i32, i32} (LocInfoE loc_39 (use{IntOp i32} (LocInfoE loc_40 ("key")))))
        then
        locinfo: loc_21 ;
          Goto "#5"
        else
        locinfo: loc_27 ;
          Goto "#6"
      ]> $
      <[ "#5" :=
        locinfo: loc_21 ;
        LocInfoE loc_22 ("lo") <-{ IntOp i32 }
          LocInfoE loc_23 ((LocInfoE loc_24 (use{IntOp i32} (LocInfoE loc_25 ("mid")))) +{IntOp i32, IntOp i32} (LocInfoE loc_26 (i2v 1 i32))) ;
        locinfo: loc_13 ;
        Goto "#1"
      ]> $
      <[ "#6" :=
        locinfo: loc_27 ;
        LocInfoE loc_28 ("hi") <-{ IntOp i32 }
          LocInfoE loc_29 (use{IntOp i32} (LocInfoE loc_30 ("mid"))) ;
        locinfo: loc_13 ;
        Goto "#1"
      ]> $
      <[ "#7" :=
        locinfo: loc_41 ;
        Return (LocInfoE loc_42 (use{IntOp i32} (LocInfoE loc_43 ("mid"))))
      ]> $
      <[ "#8" :=
        locinfo: loc_31 ;
        Goto "#4"
      ]> $∅
    )%E
  |}.
End code.
