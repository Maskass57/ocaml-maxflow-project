open Graph
open Printf
open Gfile

(**
   Reads a line containing a node.
   @param graph : input_label graph
   @param line : string
   @return : input_label graph, the graph with the created node
*)let read_node_aps graph line =
    try 
      Scanf.sscanf line "n %s %d" (fun _ id -> new_node graph id)
    with e ->
      Printf.printf "Cannot read node in line - %s:\n%s\n%!" (Printexc.to_string e) line ;
      failwith "read_node_aps"

(**
   Reads a line containing an arc.
   @param graph : input_label graph
   @param line : string
   @return : input_label graph, the graph with the created arc
*)
let read_arc_aps graph line =
  try Scanf.sscanf line "a %d %d %d"
        (fun src tgt lbl-> new_arc (ensure (ensure graph src) tgt) { src=src ; tgt=tgt ; lbl=lbl } )
  with e ->
    Printf.printf "Cannot read arc in line - %s:\n%s\n%!" (Printexc.to_string e) line ;
    failwith "read_arc_aps"


(**
   Takes a graph and returns 4 variables containing: origin-people-sports-destination.
   The nodes are partitioned depending of the values decided:
   source = 1000, destination = 1001, people between 1 and 99, sports between 100 and 1000
   @param graph : 'a graph, input graph
   @return : id * id list * id list * id, containing: source, people list, sports list, destination 
*) 
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
  partition (1000, [], [], 1001) nodes

(**
   Reads the file found at path and returns the id graph.
   @param path : string, path to access the file
   @return : id graph, the graph generated
*)
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

(**
   Adds origin and destination nodes to the id graph as this is not something present in the .txt files.
   @param graph : id graph, the graph given in input
   @return : id graph, the graph with origin and destination nodes.
*)
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


(**
   Writes a string graph in dot format, but under a bipartite view (the format understood by graphviz).
   We used the nodes partitioning to separated the differend nodes categories in subgraphs.
   @param path : path, the path where we will write the file
   @param gr : path graph, the graph that we read values from
   @return : unit, nothing to return.
*)
let exportAPS path gr =
  let indent = "  " in
  (* Open a write-file. *)
  let ff = open_out path in
  (* Write in this file. *)
  fprintf ff "digraph finite_state_machine {\n" ;
  fprintf ff "%ssize=\"8,48\";\n" indent;
  fprintf ff "%srankdir=LR;\n" indent;
  fprintf ff "%sranksep=2.0;\n" indent;  (* Increase the vertical space between nodes *)
  fprintf ff "%sranksep=7.0;\n" indent;  (* Increase the horizontal space between columns *)

  fprintf ff "%snode [fontsize=32, width=1.2, height=1.2];\n" indent; (* Adjust node size and font size *)
  fprintf ff "%sedge [fontsize=24];\n" indent;  (* Adjust edge label font size *)

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
