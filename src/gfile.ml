open Graph
open Printf

type path = string

(* Format of text files:
   % This is a comment

   % A node with its coordinates (which are not used), and its id.
   n 88.8 209.7 0
   n 408.9 183.0 1

   % Edges: e source dest label id  (the edge id is not used).
   e 3 1 11 0 
   e 0 2 8 1

*)

(* Compute arbitrary position for a node. Center is 300,300 *)
let iof = int_of_float
let foi = float_of_int

let index_i id = iof (sqrt (foi id *. 1.1))

let compute_x id = 20 + 180 * index_i id

let compute_y id =
  let i0 = index_i id in
  let delta = id - (i0 * i0 * 10 / 11) in
  let sgn = if delta mod 2 = 0 then -1 else 1 in

  300 + sgn * (delta / 2) * 100
  

let write_file path graph =

  (* Open a write-file. *)
  let ff = open_out path in

  (* Write in this file. *)
  fprintf ff "%% This is a graph.\n\n" ;

  (* Write all nodes (with fake coordinates) *)
  n_iter_sorted graph (fun id -> fprintf ff "n %d %d %d\n" (compute_x id) (compute_y id) id) ;
  fprintf ff "\n" ;

  (* Write all arcs *)
  let _ = e_fold graph (fun count arc -> fprintf ff "e %d %d %d %s\n" arc.src arc.tgt count arc.lbl ; count + 1) 0 in
  
  fprintf ff "\n%% End of graph\n" ;
  
  close_out ff ;
  ()

(* Reads a line with a node. *)
let read_node graph line =
  try Scanf.sscanf line "n %f %f %d" (fun _ _ id -> new_node graph id)
  with e ->
    Printf.printf "Cannot read node in line - %s:\n%s\n%!" (Printexc.to_string e) line ;
    failwith "from_file c"

(* Ensure that the given node exists in the graph. If not, create it. 
 * (Necessary because the website we use to create online graphs does not generate correct files when some nodes have been deleted.) *)
let ensure graph id = if node_exists graph id then graph else new_node graph id

(* Reads a line with an arc. *)
let read_arc graph line =
  try Scanf.sscanf line "e %d %d %_d %s@%%"
        (fun src tgt lbl -> let lbl = String.trim lbl in new_arc (ensure (ensure graph src) tgt) { src ; tgt ; lbl } )
  with e ->
    Printf.printf "Cannot read arc in line - %s:\n%s\n%!" (Printexc.to_string e) line ;
    failwith "from_file b"

(* Reads a comment or fail. *)
let read_comment graph line =
  try Scanf.sscanf line " %%" graph
  with _ ->
    Printf.printf "Unknown line:\n%s\n%!" line ;
    failwith "from_file a"

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

let from_file path =

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
          | 'n' -> read_node graph line
          | 'e' -> read_arc graph line

          (* It should be a comment, otherwise we complain. *)
          | _ -> read_comment graph line
      in      
      loop graph2

    with End_of_file -> graph (* Done *)
  in

  let final_graph = loop empty_graph in
  
  close_in infile ;
  final_graph

(*Writes a string graph in dot format (the format understood by graphviz)*)
let export path gr =
  let indent = "  " in
  (* Open a write-file. *)
  let ff = open_out path in
  (* Write in this file. *)
  fprintf ff "digraph finite_state_machine {\n" ;
  
  n_iter_sorted gr (fun id -> fprintf ff "%s%d;\n" indent id) ;
  e_iter gr (fun id -> fprintf ff "%s%d -> %d [label = \"%s\"];\n" indent id.src id.tgt id.lbl) ;
  
  fprintf ff "}\n" ;
  close_out ff ;
;;

  
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