open Graph
open Printf

let ensure graph id = if node_exists graph id then graph else new_node graph id

let read_comment graph line =
  try Scanf.sscanf line " %%" graph
  with _ ->
    Printf.printf "Unknown line:\n%s\n%!" line ;
    failwith "read_comment"

(* Reads a line with a node *)
let read_node_aps graph line =
  try 
  print_endline ("Input line: " ^ line);
  Scanf.sscanf line "n %s %d" (fun _ id -> new_node graph id)
  with e ->
    Printf.printf "Cannot read node in line - %s:\n%s\n%!" (Printexc.to_string e) line ;
    failwith "read_node_aps"

(* Reads a line with an arc *)
let read_arc_aps graph line =
  print_endline ("Input line: " ^ line);
  try Scanf.sscanf line "a %d %d %d"
        (fun src tgt lbl-> new_arc (ensure (ensure graph src) tgt) { src=src ; tgt=tgt ; lbl=lbl } )
  with e ->
    Printf.printf "Cannot read arc in line - %s:\n%s\n%!" (Printexc.to_string e) line ;
    failwith "read_arc_aps"


(* Takes a graph and returns 4 variables containing: origin-people-sports-destination*)    
let partition_nodes graph =
  let rec partition (origin, col1, col2, destination) nodes =
    match nodes with
    | [] -> (origin, col1, col2, destination)
    | id :: rest ->
        if id >= 1 && id < 100 then
          partition (origin, id :: col1, col2, destination) rest  (* Add to col1 : people list *)
        else if id == 1000 then
          partition (id,col1,col2,destination) rest
        else if id == 1001 then
          partition (origin,col1,col2,id) rest
        else 
          partition (origin, col1, id :: col2, destination) rest  (* Add to col2 : sports list *)
  in
  let nodes = Graph.n_fold graph (fun acc id -> id :: acc) [] in
  partition (0, [], [], 0) nodes

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
;;



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


 (*Writes a string graph in dot format, but under a bipartite view (the format understood by graphviz)*)

 let exportAPS path gr =
  let indent = "  " in
  (* Open a write-file. *)
  let ff = open_out path in
  (* Write in this file. *)
  fprintf ff "digraph finite_state_machine {\n" ;
  fprintf ff "%srankdir=LR;\n" indent;

  (* We get people list, then sports list *)
  let origin, col1, col2, destination = partition_nodes gr in

  (*Origin part*)
  Printf.fprintf ff "%ssubgraph cluster_origin {\n" indent ;
  Printf.fprintf ff "%s%slabel=\"Origin\";\n" indent indent;
  Printf.fprintf ff "%s%scolor=\"Green\";\n" indent indent;
  Printf.fprintf ff "%s%s%d;\n" indent indent origin;
  Printf.fprintf ff "%s}\n" indent ;

  (*Students part*)
  Printf.fprintf ff "%ssubgraph cluster_people {\n" indent ;
  Printf.fprintf ff "%s%slabel=\"People\";\n" indent indent;
  Printf.fprintf ff "%s%scolor=\"Red\";\n" indent indent;
  List.iter (fun id -> Printf.fprintf ff "%s%s%d;\n" indent indent id) col1 ;
  Printf.fprintf ff "%s}\n" indent ;

  (*Sports part*)
  Printf.fprintf ff "%ssubgraph cluster_sports {\n" indent ;
  Printf.fprintf ff "%s%slabel=\"Sports\";\n" indent indent;
  Printf.fprintf ff "%s%scolor=\"Blue\";\n" indent indent;  
  List.iter (fun id -> Printf.fprintf ff "%s%s%d;\n" indent indent id) col2 ;
  Printf.fprintf ff "%s}\n" indent ;

  (*Destination part*)
  Printf.fprintf ff "%ssubgraph cluster_destination {\n" indent ;
  Printf.fprintf ff "%s%slabel=\"Destination\";\n" indent indent;
  Printf.fprintf ff "%s%scolor=\"Purple\";\n" indent indent;
  Printf.fprintf ff "%s%s%d;\n" indent indent destination;
  Printf.fprintf ff "%s}\n" indent ;

  e_iter gr (fun id -> fprintf ff "%s%d -> %d [label = \"%s\"];\n" indent id.src id.tgt id.lbl) ;
  
  fprintf ff "}\n" ;
  close_out ff ;
