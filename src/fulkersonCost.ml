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

let initialize_dijkstra_graph graph start =
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
            | Some (dest,{cost=actual_cost;prev=actual_prev}) -> 
                let new_cost = label.cost + lbl.cost in 
                if (new_cost < actual_cost) then
                    (dest,{cost=new_cost;prev=Some node})::List.filter (fun (nodeAux,_) -> nodeAux <> dest) list  
                else 
                    acc 
        ) list out_arcs 

let get_node = function 
    | Some x -> x
    | None -> failwith "aargh.."

let dijkstra graph start target = 
    let rec dijkstra_aux list visited = 
        let current_node = find_min_node list in 
        match (current_node) with
            | None -> list 
            | Some (node,_) when node = target -> list
            | Some (node,label) ->
                let new_list = List.filter (fun (node_aux,_) -> node_aux = node) list in
                let updated_list = update_neighbours graph new_list (get_node current_node) in 
                dijkstra_aux updated_list ((node,label)::visited)
    in
        dijkstra_aux (initialize_dijkstra_graph graph start) []

let rec reconstruct_path acc visited target =

    match (List.find_opt (fun (node,{cost=_;prev=Some father}) -> node = target) visited) with
        |  None -> acc 
        | Some (node_aux,label_aux) -> reconstruct_path ((node_aux,label_aux)::acc) visited node_aux  

let rec find_min_cost target = function 
    | [] -> failwith "error pattern matching find_min_cost"
    | (node_aux,label_aux)::rest -> 
        if (node_aux = target) 
            then label_aux.cost 
            else find_min_cost target rest

let rec find_min_flow graph minimum = function 
    | [] -> minimum 
    | [_] -> minimum
    | (node,_)::(node_aux,label_aux)::rest -> 
        let arc = List.find (fun {src=src;tgt=tgt;lbl=_} -> src=node && tgt=node_aux) (out_arcs graph node) in 
        let new_minimum = min arc.lbl.cost minimum in 
        find_min_flow graph new_minimum ((node_aux,label_aux)::rest)

(*
let rec updateEdgeGraph_cost gr dijkstraResult = 
    let min_flow = find_min_flow gr max_int dijkstraResult in 
    let edgegraphed = edgeGraph_cost gr in 
    match dijkstraResult with
    | (nodex,_)::(nodey,labely)::rest -> 
        let arc = List.find (fun {src=src;tgt=tgt;lbl=lbl} -> src = nodex && tgt = nodey ) (out_arcs gr nodex) in
        let gr1 = add_arc_cost edgegraphed nodex nodey ({flow = (-min_flow);cost=arc.lbl.cost}) in 
        updateEdgeGraph_cost edgeGraph_cost (add_arc_cost gr1 nodex nodey ({flow = (min_flow);cost=-arc.lbl.cost})) (((nodey,labely)::rest),min_flow)
    | _x::[] -> gr
    | [] -> gr
          

*)