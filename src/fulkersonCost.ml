open Tools
open Graph
open Gfile

type input_label = {capa:id;cost:id}
type input_graph =  input_label graph

type fulkerson_label_cost = {flow : id; capa : id; cost: id}
type fulkerson_graphs_cost = fulkerson_label_cost graph
type node = id
type edgegraph_label = {flow:id;cost:id}
type edgegraph_cost = edgegraph_label graph

let createArcs_cost = function  | {src = s ; tgt = d ; lbl = {flow = f ; capa = c ; cost = co}} -> 
  ({ src = s ; tgt = d ; lbl = {flow = c-f;capa = c;cost = co}} , { src = d ; tgt = s ; lbl = {flow = f ; capa = c; cost = -co}})

let convertGraph_Cost gr = gmap gr (fun (lbl:input_label) -> {flow=0;capa=lbl.capa;cost=lbl.cost})

let  add_arc_cost gr src tgt {flow;cost} = 
  match (find_arc gr src tgt) with
  | None -> new_arc gr {src=src; tgt=tgt;lbl={flow;cost}}
  | Some existing_label ->
    let updated_label = {
      flow = existing_label.lbl.cost + flow;
      cost = max cost (existing_label.lbl.cost); 
    } in
    new_arc gr {src;tgt; lbl = updated_label}

let edgeGraph_cost (gr: fulkerson_graphs_cost) = 
  e_fold gr (fun grb arc -> let (arc1, arc2)= createArcs_cost arc in 
              let ngrb = add_arc_cost grb arc1.src arc1.tgt {flow = arc1.lbl.flow; cost=arc1.lbl.cost} in 
              add_arc_cost ngrb arc2.src arc2.tgt {flow = arc2.lbl.flow; cost=arc2.lbl.cost} ) (clone_nodes gr)


type 'a dijkstra_label = {cost: int; prev: 'a option}
type 'a dijkstra_graph = ('a * 'a dijkstra_label) list


let initialize_dijkstra_graph (graph: fulkerson_graphs_cost) start : node dijkstra_graph =
  let nodes = n_fold graph (fun acc id -> id :: acc) [] in
  List.map
    (fun node ->
       if node = start then
         (node, {cost = 0; prev = None})  
       else
         (node, {cost = max_int; prev = None}) 
    )
    nodes

let find_min_node list =
  List.fold_left
    (fun acc (node, label) ->
       match acc with
       | None -> Some (node, label)
       | Some (_, {cost = d; _}) -> if label.cost < d then Some (node, label) else acc
    )
    None
    list



let update_neighbours graph list (node,label) = 
  let out_arcs = out_arcs graph node in 

  List.fold_left (fun acc ({src=_;tgt=tgt;lbl=lbl}) -> 
      let neighbour = List.find_opt (fun (node,_) -> node = tgt) acc in 
      match neighbour with 
      | None -> acc
      | Some (dest,{cost=actual_cost;prev=_}) -> 
        let new_cost = label.cost + lbl.cost in 
        if (new_cost < actual_cost) then
          (dest,{cost=new_cost;prev=Some node})::List.filter (fun (nodeAux,_) -> nodeAux <> dest) list  
        else 
          acc 
    ) list out_arcs 

let get_node = function 
  | Some x -> x
  | None -> failwith "get_node failed"

let convert_dijkstra_to_fulkerson (node, dijkstra_label) =
  { flow = 0; (* Flow is not part of Dijkstra's algorithm, so it's initialized to 0 *)
    capa = 0; (* Capacity is also not part of Dijkstra, so initialized to 0 *)
    cost = dijkstra_label.cost }  (* The cost in the Dijkstra label becomes the cost in the Fulkerson label *)
let convert_dijkstra_graph_to_fulkerson_graph (dijkstra_graph: 'a dijkstra_label graph) : fulkerson_graphs_cost =
  gmap dijkstra_graph (fun dijkstra_label ->
      (* Convert dijkstra_label to fulkerson_label_cost *)
      { flow = 0;       (* No flow in Dijkstra, so initialize to 0 *)
        capa = 0;       (* Capacity is unknown, so set to 0 *)
        cost = dijkstra_label.cost }  (* The cost from Dijkstra is directly used *)
    )

let dijkstra graph start target = 
  let rec dijkstra_aux list visited = 
    let current_node = find_min_node list in 
    match (current_node) with
    | None -> list 
    | Some (node,_) when node = target -> list
    | Some (node,label) ->
      let new_list = List.filter (fun (node_aux,_) -> node_aux = node) list in
      let updated_list = update_neighbours graph new_list (node,label) in 
      dijkstra_aux updated_list ((node,label)::visited)
  in
  dijkstra_aux (initialize_dijkstra_graph (convert_dijkstra_graph_to_fulkerson_graph graph) start) []

let rec reconstruct_path acc visited target =

  match (List.find_opt (fun (node,{cost=_;prev=_}) -> node = target) visited) with
  |  None -> acc 
  | Some (node_aux,label_aux) -> reconstruct_path ((node_aux,label_aux)::acc) visited node_aux  

let rec find_min_cost target = function 
  | [] -> failwith "error pattern matching find_min_cost"
  | (node_aux,label_aux)::rest -> 
    if (node_aux = target) 
    then label_aux.cost 
    else find_min_cost target rest

let rec find_min_flow graph minimum (dijkstra_graph: int dijkstra_graph)= match (dijkstra_graph) with 
  | [] -> minimum 
  | [_] -> minimum
  | (node,_)::(node_aux,label_aux)::rest -> 
    let arc = List.find (fun {src=src;tgt=tgt;lbl=_} -> src=node && tgt=node_aux) (out_arcs graph node) in 
    let new_minimum = min arc.lbl.flow minimum in 
    find_min_flow graph new_minimum ((node_aux,label_aux)::rest)

let rec updateEdgeGraph_cost gr (dijkstraResult:'a dijkstra_graph) min_flow = 
  (*let min_flow = find_min_flow gr max_int dijkstraResult in*)
  match dijkstraResult with
  | (nodex,_)::(nodey,labely)::rest -> 
    let arc = List.find (fun {src=src;tgt=tgt;lbl=_} -> src = nodex && tgt = nodey ) (out_arcs gr nodex) in
    let gr1 = add_arc_cost gr nodex nodey ({flow = (-min_flow);cost=arc.lbl.cost}) in 
    let gr2 = add_arc_cost gr1 nodex nodey ({flow = (min_flow);cost=(-arc.lbl.cost)}) in
    updateEdgeGraph_cost gr2 (((nodey,labely)::rest)) min_flow
  | _x::[] -> gr
  | [] -> gr

let getVal_cost = function
  | Some x -> x
  | None -> raise (Graph_error("No path found"))

let convertEdge_cost ownEdgeType =
  gmap ownEdgeType (fun {flow=flow;cost=_} -> flow)

let unEdgeGraph_cost startGraph eGraph =
  (*gmap startGraph (fun x -> let newVal = (getVal (find_arc eGraph x.tgt x.src)).lbl in {flow = newVal; capa = x.lbl.capa}  )*)
  let newEdge = convertEdge_cost eGraph in 
  e_fold startGraph (fun acu x  -> 
      let capaInverse = match find_arc startGraph x.tgt x.src with
        | Some arc -> arc.lbl.capa
        | None -> 0
      in 
      let newVal = (getVal_cost (find_arc newEdge x.tgt x.src)).lbl - capaInverse in 
      if (newVal >= 0) 
      then new_arc acu {src=x.src; tgt=x.tgt; lbl={flow=newVal; capa=x.lbl.capa;cost=x.lbl.cost}}
      else new_arc acu {src=x.src; tgt=x.tgt; lbl={flow=0; capa=x.lbl.capa;cost=x.lbl.cost}}) (clone_nodes startGraph)

let grapheJoli (gr:fulkerson_graphs_cost) = gmap gr (fun x -> string_of_int x.flow ^ "/" ^ string_of_int x.capa)

let dijkstra_list_to_graph (dijkstra_result: node dijkstra_graph) : node dijkstra_label graph =
  (* Start by creating a graph with just the nodes *)
  let graph_with_nodes = List.fold_left (fun acc (node, _) -> new_node acc node) empty_graph dijkstra_result in

  (* Add edges corresponding to the predecessor links in the dijkstra_result *)
  List.fold_left
    (fun acc (node, { prev; cost }) ->
       match prev with
       | Some prev_node ->
         let arc = { src = prev_node; tgt = node; lbl = { cost = cost; prev = Some prev_node } } in
         new_arc acc arc  (* Add the constructed arc to the graph *)
       | None -> acc  (* No edge if there's no predecessor *)
    )
    graph_with_nodes
    dijkstra_result

let print_dijkstra_path (path: node dijkstra_graph) =
  let formatted_path =
    String.concat " -> " (List.map (fun (node, _) -> string_of_int node) path)
  in
  Printf.printf "Path found: [%s]\n" formatted_path
(* Convert edgegraph_label to fulkerson_label_cost by adding a default capa *)
let convert_edgegraph_to_fulkerson_label (edge_label: edgegraph_label) : fulkerson_label_cost =
  { flow = edge_label.flow; cost = edge_label.cost; capa = 0 }  (* You can set capa based on your logic *)

let convert_edgegraph_graph_to_fulkerson (gr: edgegraph_label graph) : fulkerson_graphs_cost =
  gmap gr (fun { flow; cost } -> { flow; cost; capa = 0 })  (* Convert each edge *)

(* Function to convert fulkerson_label_cost to edgegraph_label *)
let convert_fulkerson_to_edgegraph_label (f: fulkerson_label_cost) : edgegraph_label =
  { flow = f.flow; cost = f.cost }  (* Ignore capa field *)

(* Function to convert a full fulkerson_graphs_cost to edgegraph_label graph *)
let convert_fulkerson_graph_to_edgegraph (gr: fulkerson_graphs_cost) : edgegraph_label graph =
  gmap gr (fun { flow; cost; _ } -> { flow; cost })  (* Ignore capa field *)

let fordFulkerson gr origin destination =
  let fulkerson = convertGraph_Cost gr in 
  let eGraph = edgeGraph_cost fulkerson in

  let mappedEGraph = gmap eGraph (fun x -> string_of_int x.flow ^ "-" ^ string_of_int x.cost) in
  export ("./test.dot") mappedEGraph;

  let rec fordFulkersonAux gr1 i= 
    let start_graph = initialize_dijkstra_graph gr1 1000 in 
    let temp = unEdgeGraph_cost fulkerson eGraph in 
    let joli = grapheJoli temp in
    export ("./" ^ (string_of_int i) ^ ".dot") joli;
    match dijkstra (dijkstra_list_to_graph start_graph) origin destination with
    | [] -> gr1
    | list -> 

      print_dijkstra_path list;
      let edged = edgeGraph_cost temp in
      if(list=[]) then gr1 
      else

        let min_flow = find_min_flow edged max_int list in 
        fordFulkersonAux (convert_edgegraph_graph_to_fulkerson (updateEdgeGraph_cost edged start_graph min_flow)) (i+1) 
  in
  unEdgeGraph_cost fulkerson (convert_fulkerson_graph_to_edgegraph (fordFulkersonAux fulkerson 0))

