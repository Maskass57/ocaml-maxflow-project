open Gfile
open Tools
open FulkersonCost
open Apsgraph
open Apscost
open Gui

let () =

  (* Check the number of command-line arguments *)
  if Array.length Sys.argv <> 5 then
    begin
      Printf.printf
        "\n ✻  Usage: %s infile source sink outfile\n\n%s%!" Sys.argv.(0)
        ("    🟄  infile  : input file containing a graph\n" ^
         "    🟄  source  : identifier of the source vertex (used by the ford-fulkerson algorithm)\n" ^
         "    🟄  sink    : identifier of the sink vertex (ditto)\n" ^
         "    🟄  outfile : output file in which the result should be written.\n\n") ;
      exit 0
    end ;


  (* Arguments are : infile(1) source-id(2) sink-id(3) outfile(4) *)

  let infile = Sys.argv.(1)
  and outfile = Sys.argv.(4)

  (* These command-line arguments are not used for the moment. *)
  and _source = int_of_string Sys.argv.(2)
  and _sink = int_of_string Sys.argv.(3)
  in

  (* Open file *)
  (*
  let graph = from_file infile in
  let graph_int = gmap graph (fun x -> int_of_string x) in
  let fulkerson = convertGraph graph_int in 
  let _fulkerson_joli = grapheJoli fulkerson in 

  let _fulkerson_Int = gmap fulkerson (fun x -> x.flow) in
  let _new_graph = clone_nodes graph in
  let _mapped_graph = gmap graph (fun _x -> "a") in 
  let mapped_graph_path = gmap graph (fun x -> int_of_string x) in
  let added_arc = add_arc mapped_graph_path 3 3 3 in
  let _mapped_graph_int = gmap added_arc (fun x -> string_of_int x) in

  let ford_graph = edgeGraph fulkerson in

  let _ford_graph_mapped = gmap ford_graph (fun x -> string_of_int x) in 
  *)

  (* Rewrite the graph that has been read. *)
  let aps = from_file_aps_cost infile in
  let aps_complete = add_origin_destination_cost aps 1 in 
  let (aps_ffulk,cost) = fordFulkerson aps_complete 1000 1001 in
  Printf.printf "%s%sCout total : %s%d\n" bold yellow reset cost ;
  let aps_ffulk_joli = grapheJoli aps_ffulk in
  let () = write_file outfile aps_ffulk_joli in

  ();

  (*let _testFordFulk = fordFulkerson graph_int 0 5 in
    export "./normal.dot" graph;
    export "./joli.dot" fulkerson_joli;
  *)

  exportAPS "./aps.dot" aps_ffulk_joli;
  Printf.printf "%s%sCout total : %s%d\n" bold yellow reset (getCostGraph aps_ffulk);

  ignore (Thread.create gui_display aps_ffulk);
  Printf.printf "Le programme principal continue d'exécuter son code pendant que le GUI est en arrière-plan.\n";
  GMain.main ();
