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
      