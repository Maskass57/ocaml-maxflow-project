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

  (* Rewrite the graph that has been read. *)
  let aps = from_file_aps_cost infile in
  let aps_complete = add_origin_destination_cost aps 1 in 
  let (aps_ffulk,cost) = fordFulkerson aps_complete sourceConstante destinationConstante in
  Printf.printf "%s%sCout total renvoyé par ford fulkerson: %s%d\n" bold yellow reset cost ;
  let aps_ffulk_joli = grapheJoli aps_ffulk in
  let () = write_file outfile aps_ffulk_joli in

  exportAPS "./aps.dot" aps_ffulk_joli;
  Printf.printf "%s%sCout total renvoyé par getCostGraph: %s%d\n" bold yellow reset (getCostGraph aps_ffulk);

  gui_display aps_ffulk;
