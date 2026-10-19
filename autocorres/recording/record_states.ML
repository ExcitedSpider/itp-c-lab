(* Inspect states retained by Isabelle's standard theory loader.
   The source theory and its proof commands are not rewritten. *)
structure Lab_Record =
struct
fun field name value = XML.Elem ((name, []), [XML.Text value]);
fun number opt = string_of_int (the_default ~1 opt);
fun segment ({span, command, state, ...}: Document_Output.segment) =
  let
    val _ = if Toplevel.is_skipped_proof state then error "Skipped proof in recording" else ();
    val (first, last) = Command_Span.range span;
    val source = implode (map Token.source_of (Command_Span.content span));
    val output = Pretty.pure_string_of (Pretty.chunks (Toplevel.pretty_state state));
  in XML.Elem (("step", [
       ("name", Toplevel.name_of command),
       ("start_symbol", number (Position.offset_of first)),
       ("end_symbol", number (Position.offset_of last)),
       ("line", number (Position.line_of first)),
       ("proof_open", Bool.toString (Toplevel.is_proof state))]),
       [field "command" source, field "output" output])
  end;
fun record_file source_path output_path =
  let
    val options = Options.default ()
      |> Options.put_bool "record_theories" true
      |> Options.put_bool "quick_and_dirty" false;
    val loaded = Thy_Info.use_theories options Resources.default_qualifier
      [(source_path, Position.none)];
    val (thy, segments) = List.last loaded;
    val name = Context.theory_long_name thy;
    val _ = if null segments then error "No retained theory states" else ();
    val tree = XML.Elem (("recording", [("theory", name)]), map segment segments);
    val _ = File.write (Path.explode output_path) (XML.string_of tree);
  in writeln ("RECORDED " ^ name ^ ": " ^ string_of_int (length segments) ^ " theory commands") end;
end;
