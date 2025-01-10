open Tools
open Graph

type input_label = {capa:id;cost:id}
type input_graph =  input_label graph

type fulkerson_label_cost = {flow : id; capa : id; cost: id}
type fulkerson_graphs_cost = fulkerson_label_cost graph
type edgegraph_label = {flow:id;cost:id}
type edgegraph_cost = edgegraph_label graph

(*
  Dijkstra label, used in a hashtbl
  Contains the cost to reach the node, the previous node, and if the node is marked.
*)
type 'a dijkstra_label = {cost: int; prev: 'a option; marked: bool}

(**
   Create 2 arcs from the input arc.
   Maps a arc of a input graph into the arcs of the edgegraph.
   @param arc : fulkerson_label_cost arc to map.
   @return : (edgegraph_label arc, edgegraph_label arc), tuple of edgegraph label arcs.
*)
let createArcs_cost = function  | {src = s ; tgt = d ; lbl = {flow = f ; capa = c ; cost = co}} -> 
  ({ src = s ; tgt = d ; lbl = {flow = c-f;capa = c;cost = co}} , { src = d ; tgt = s ; lbl = {flow = f ; capa = c; cost = -co}})

(**
   Convert an input_graph into a fulkerson_graphs_cost
   @param gr : input graph.
   @return : fulkerson_graphs_cost.
*)
let convertGraph_Cost gr = gmap gr (fun (lbl:input_label) -> {flow=0;capa=lbl.capa;cost=lbl.cost})

(**
   Adds a edgegraph_label arc
   If the arc already exists, incoming flow is added to existing flow. 
   If arc doesn't exist, we simply create it.
   @param gr : input edgegraph_cost.
   @param src : source node.
   @param tgt : target node.
   @param label : label of the arc.
   @return : edgegraph_cost.
*)
let  add_arc_cost gr src tgt label =
  match (find_arc gr src tgt) with
  | None -> new_arc gr {src=src; tgt=tgt;lbl=label}
  | Some existing_label ->
    let updated_label = {
      flow = existing_label.lbl.flow + label.flow;
      cost = existing_label.lbl.cost; 
    } in
    new_arc gr {src=src;tgt=tgt; lbl = updated_label}

(**
   Convert a fulkerson_graphs_cost into a edgegraph_label graph
   @param gr : input fulkerson_graphs_cost.
   @return : edgegraph_label graph.
*)
let edgeGraph_cost (gr: fulkerson_graphs_cost) = 
  e_fold gr (fun grb arc -> let (arc1, arc2)= createArcs_cost arc in 
              let ngrb = add_arc_cost grb arc1.src arc1.tgt {flow = arc1.lbl.flow; cost=arc1.lbl.cost} in 
              add_arc_cost ngrb arc2.src arc2.tgt {flow = arc2.lbl.flow; cost=arc2.lbl.cost} ) (clone_nodes gr)


(**
   Initializes the hashtbl with the starting edgegraph_label graph
   @param gr : input edgegraph_label graph.
   @param src : source node
   @return : hashtbl(node, dijkstra_label).
*)

(**
   Counts nodes in a graph
   @param gr : input graph.
   @return : int.
*)
let count_nodes (graph: 'a graph)=
  n_fold graph (fun _ acu -> acu+1) 0

(**
   Initializes dijkstra hashtbl
   @param graph : input graph.
   @return : Hashtbl.
*)
let initialize_dijkstra_hashtbl graph src = 
  let hashtbl = Hashtbl.create (count_nodes graph) in
  n_iter graph (fun node -> 
      if(node=src) 
      then Hashtbl.add hashtbl node {cost=0;prev=None;marked=false} 
      else Hashtbl.add hashtbl node {cost=max_int;prev=None;marked=false});
  hashtbl

(**
   Find the node with minimal cost in the hashtbl
   @param hashtbl : hashtbl.
   @return : (node,min).
*)
let find_min_node hashtbl =
  Hashtbl.fold
    (fun node label acc ->
       let (_, min) = acc in
       if (label.cost < min && (not label.marked)) then
         ((Some node),label.cost)
       else 
         acc
    )
    hashtbl
    (None,max_int)

(**
   Updates neighbours of a node in the hashtbl and returns unit.
   @param graph : edgegraph_label graph.
   @param hashtbl : hashtbl.
   @param (node,cost) : (node,int).
   @return : unit.
*)
let update_neighbours graph hashtbl (node,cost) = 
  let out_arcs = out_arcs graph node in 

  List.iter 
    (fun {src=_;tgt=tgt;lbl={flow=flowArc;cost=costArc}} -> 
       let foundLabel = Hashtbl.find hashtbl tgt in
       if (cost + costArc < foundLabel.cost && (not foundLabel.marked) && flowArc>0) then
         Hashtbl.replace hashtbl tgt {cost=cost + costArc; prev = Some node ; marked=false}
       else 
         ()
    ) out_arcs 

(**
   Removes the option of a node option.
   @param node : node option.
   @return : node.
*)    
let unOption = function 
  | Some x -> x
  | None -> failwith "get_node failed"

(**
   Reconstructs the path obtained through the hashtbl.
   @param hashtbl : hashtbl.
   @param tgt : node.
   @return : list (aka the path).
*)  
let reconstruct_path hashtbl tgt = 
  let rec reconstruct_path_aux local_dest acu = 
    let current_lbl = 
      Hashtbl.find hashtbl local_dest in 
    match (current_lbl.prev) with 
    | None -> acu 
    | Some (node) -> reconstruct_path_aux node (node::acu)
  in 
  reconstruct_path_aux tgt [tgt]

(**
   Performs dijkstra path finding on a graph with a given start and target node.
   This implementation is based on the used of the hashtbl
   @param graph : edgegraph_label graph.
   @param start : start node.
   @param start : target node.
   @return : list (aka the path).
*) 
let dijkstra graph start target = 
  let hashtbl = initialize_dijkstra_hashtbl graph start in 

  let rec dijkstra_aux () = 
    let current_node = find_min_node hashtbl in 

    match (current_node) with
    | (None,_) -> reconstruct_path hashtbl target 
    | ((Some node),_) when (node=target) -> reconstruct_path hashtbl target 
    | ((Some node),cost) -> 
      let label_founded = Hashtbl.find hashtbl node in
      Hashtbl.replace hashtbl node {cost=label_founded.cost; prev=label_founded.prev; marked=true};
      (*Unix.sleep 1;*)
      update_neighbours graph hashtbl (node,cost);
      dijkstra_aux ()
  in 
  dijkstra_aux ()

(**
   Converts a edgegraph into a fulkerson_label_cost graph.
   The new graph is built by recuperating nodes from start graph
   and integrating the changes on arcs recuperated from the edgegraph_label graph.
   @param startGraph : fulkerson_label_cost graph.
   @param eGraph : edgegraph_label graph.
   @return : fulkerson_label_cost graph, the graph returned.
*) 
let unEdgeGraph_cost startGraph eGraph =
  e_fold startGraph (fun acu x  -> 
      let capaInverse = match find_arc startGraph x.tgt x.src with
        | Some arc -> arc.lbl.capa
        | None -> 0
      in 
      let newVal = (unOption(find_arc eGraph x.tgt x.src)).lbl.flow - capaInverse in 
      if (newVal >= 0) 
      then new_arc acu {src=x.src; tgt=x.tgt; lbl={flow=newVal; capa=x.lbl.capa;cost=x.lbl.cost}}
      else new_arc acu {src=x.src; tgt=x.tgt; lbl={flow=0; capa=x.lbl.capa;cost=x.lbl.cost}}) (clone_nodes startGraph)

(**
   Maps a fulkerson_graphs_cost into a path graph. 
   @param gr : fulkerson_graphs_cost
   @return : path graph.
*) 
let grapheJoli (gr:fulkerson_graphs_cost) = gmap gr (fun x -> string_of_int x.flow ^ "/" ^ string_of_int x.capa)

let print_dijkstra_path path =
  let formatted_path =
    String.concat " -> " (List.map (fun node -> string_of_int node) path)
  in
  Printf.printf "Path found: [%s]\n" formatted_path


(**
   Find the minimal flow from the path found bu recuperating the data associated in the graph. 
   @param graph : input graph
   @param minimum : int, accumulator
   @param dijkstra_path : node list
   @return : path graph.
*) 
let rec find_min_flow graph minimum dijkstra_path= 
  match (dijkstra_path) with 
  |   [] -> minimum 
  |   [_] -> minimum
  |   node::node_aux::rest -> 
    let arc = List.find (fun {src=src;tgt=tgt;lbl=_} -> src=node && tgt=node_aux) (out_arcs graph node) in 
    let new_minimum = min arc.lbl.flow minimum in 
    find_min_flow graph new_minimum (node_aux::rest)

(**
   Update the edgegraph_label graph thanks to the path found. 
   @param gr : edgegraph_label graph
   @param path : id list, dijkstra resul
   @param min_flow : int, increment on the path
   @return : edgegraph_label graph.
*) 
let rec updateEdgeGraph_cost gr path min_flow cost = 
  (*let min_flow = find_min_flow gr max_int dijkstraResult in*)
  match path with
  | nodex::nodey::rest -> 
    let arc = List.find (fun {src=src;tgt=tgt;lbl=_} -> src = nodex && tgt = nodey ) (out_arcs gr nodex) in
    let gr1 = add_arc_cost gr nodex nodey {flow = (-min_flow);cost=arc.lbl.cost} in 
    let gr2 = add_arc_cost gr1 nodey nodex {flow = (min_flow);cost=(-arc.lbl.cost)} in

    updateEdgeGraph_cost gr2 ((nodey::rest)) min_flow (cost + arc.lbl.cost)
  | _::[] -> (gr,cost)
  | [] -> (gr,cost)

(**
   Fulkerson implementation adapted to a maxflow_mincost implementation. 
   @param gr : input_label graph.
   @param origin : source node
   @param destination : target node
   @return : fulkerson_label_cost graph
*) 
let fordFulkerson gr origin destination =
  let fulkerson = convertGraph_Cost gr in 
  let eGraph = edgeGraph_cost fulkerson in
  let rec fordFulkersonAux gr1 i= 
    let path = dijkstra gr1 origin destination in 
    if(path=[destination])then (gr1, i)
    else 
      let min_flow = find_min_flow gr1 max_int path in
    (*
    let temp = unEdgeGraph_cost fulkerson gr1 in
    let joli = grapheJoli temp in
    export ("./" ^ (string_of_int i) ^ ".dot") joli;
    *)
      print_endline (string_of_int min_flow);
      print_dijkstra_path path;
      let (newGraph, cost)= (updateEdgeGraph_cost gr1 path min_flow i) in 
      fordFulkersonAux newGraph cost
  in
  let (newGraph, cost)= fordFulkersonAux eGraph 0 in
  ((unEdgeGraph_cost fulkerson newGraph), cost) 


let getCostGraph (gr:fulkerson_graphs_cost) = 
  e_fold gr (fun acu arc -> 
      if (arc.lbl.flow = 0) 
      then acu 
      else arc.lbl.cost + acu) 0


