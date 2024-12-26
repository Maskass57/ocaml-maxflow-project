open Graph

let ensure graph id = if node_exists graph id then graph else new_node graph id

let read_comment graph line =
  try Scanf.sscanf line " %%" graph
  with _ ->
    Printf.printf "Unknown line:\n%s\n%!" line ;
    failwith "read_comment"


let read_node_aps graph line =
  try 
  print_endline ("Input line: " ^ line);
  Scanf.sscanf line "n %s %d" (fun _ id -> new_node graph id)
  (*TODO: Map*)
  with e ->
    Printf.printf "Cannot read node in line - %s:\n%s\n%!" (Printexc.to_string e) line ;
    failwith "read_node_aps"

let read_arc_aps graph line =
  print_endline ("Input line: " ^ line);
  try Scanf.sscanf line "a %d %d"
        (fun src tgt -> new_arc (ensure (ensure graph src) tgt) { src ; tgt ; lbl=1 } )
  with e ->
    Printf.printf "Cannot read arc in line - %s:\n%s\n%!" (Printexc.to_string e) line ;
    failwith "read_arc_aps"

let from_file_aps path =

  let infile = open_in path in

  (* Read all lines until end of file. *)
  let rec loop graph =
    try
      let line = input_line infile in

      (* Remove leading and trailing spaces. *)
      let line = String.trim line in

      let graph2 =
        (* Ignore empty lines *)
        if line = "" then graph

        (* The first character of a line determines its content : n or e. *)
        else match line.[0] with
          | 'n' -> read_node_aps graph line
          | 'a' -> read_arc_aps graph line

          (* It should be a comment, otherwise we complain. *)
          | _ -> read_comment graph line
      in      
      loop graph2

    with End_of_file -> graph (* Done *)
  in

  let final_graph = loop empty_graph in
  
  close_in infile ;
  final_graph


  
