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
  with e ->
    Printf.printf "Cannot read node in line - %s:\n%s\n%!" (Printexc.to_string e) line ;
    failwith "read_node_aps"

    
let read_arc_aps graph line =
  print_endline ("Input line: " ^ line);
  try Scanf.sscanf line "a %d %d %d"
        (fun src tgt lbl-> new_arc (ensure (ensure graph src) tgt) { src=src ; tgt=tgt ; lbl=lbl } )
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

let add_origin_destination graph =
  let o_graph = 
  try
    new_node graph 1000 
  with Graph_error _->
    Printf.printf "Node origin already exists";
    graph
  in
  let o_d_graph = 
  try
    new_node o_graph 1001
  with Graph_error _-> 
    Printf.printf "Node destination already exists";
    o_graph
  in

  let nodes = Graph.n_fold graph (fun acc id -> id :: acc) [] in
  
  let add_arcs final_graph nodes =
    let rec add_arc_aux current_graph = function
      | [] -> current_graph 
      | id :: rest ->
        let updated_graph = 
          if (id >= 1 && id < 100) then 
            new_arc current_graph {src=1000;tgt=id;lbl=1}
          (*else if (id > 100 && id <1000) then
            new_arc current_graph {src=id;tgt=1001;lbl=1}
            *)
          else 
            current_graph in
        add_arc_aux updated_graph rest  
    in
    add_arc_aux final_graph nodes in

  add_arcs o_d_graph nodes
;;
