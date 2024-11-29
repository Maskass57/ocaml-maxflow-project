open Tools
open Graph

type fulkerson_label = {flow : id; capa : id}
type fulkerson_graphs = fulkerson_label graph

let createArcs = function  | {src = s ; tgt = d ; lbl = {flow = f ; capa = c}} -> 
    ({ src = s ; tgt = d ; lbl = {flow = c-f;capa = c}} , { src = d ; tgt = s ; lbl = {flow = f ; capa = c}})

let convertGraph gr = gmap gr (fun lbl -> {flow=0;capa=lbl})

let edgeGraph (gr: fulkerson_graphs) = 
  e_fold gr (fun grb arc -> let (arc1, arc2)= createArcs arc in 
  let ngrb = add_arc grb arc1.src arc1.tgt arc1.lbl.flow in 
  add_arc ngrb arc2.src arc2.tgt arc2.lbl.flow ) (clone_nodes gr)
  
  (*
  gmap gr (
  fun arc -> (let (arc1,arc2) = createArcs arc in 
  
  let ngrb = add_arc (convertGraph gr) arc1.src arc1.tgt arc1.lbl.flow in
  
  add_arc ngrb arc2.src arc2.tgt arc2.lbl.flow)) *)