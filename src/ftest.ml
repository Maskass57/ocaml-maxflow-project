open Gfile
(*open Tools*)
open FulkersonCost
open Apsgraph
open Apscost

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
  let aps_complete = add_origin_destination_cost aps in
  let aps_ffulk = fordFulkerson aps_complete 1000 1001 in 
  let aps_ffulk_joli = grapheJoli aps_ffulk in 
  
  (*let aps_mapped = gmap aps_ffulk_joli (fun x -> int_of_string x) in*)

  let () = write_file outfile aps_ffulk_joli in
  
  ();

  (*let _testFordFulk = fordFulkerson graph_int 0 5 in
    export "./normal.dot" graph;
    export "./joli.dot" fulkerson_joli;
  *)

  exportAPS "./aps.dot" aps_ffulk_joli;

  (*export "./export.dot" _ford_graph_mapped;

    let dfs_result = dfs ford_graph 0 5 in
    let _converted_result = get_list dfs_result in

    let unOptionedResult = unOption dfs_result in
    let dfs1st = updateEdgeGraph ford_graph unOptionedResult in
    let _mapped_dfs1st = gmap dfs1st (fun x -> string_of_int x) in
    let _testFordFulk_mapped = grapheJoli _testFordFulk in

    export "./dfs1st.dot" _mapped_dfs1st;
    export "./testFinal.dot" _testFordFulk_mapped;
    (*Printf.printf "Path found: [%s] and min: %s\n"
      (String.concat " -> " (List.map string_of_int converted_result)) (string_of_int (get_min dfs_result))*)
  *)