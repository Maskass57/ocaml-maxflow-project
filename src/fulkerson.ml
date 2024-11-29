open Tools
open Graph

type fulkerson_label = {flow : id; capa : id}
type fulkerson_graphs = fulkerson_label graph
type node = id

let createArcs = function  | {src = s ; tgt = d ; lbl = {flow = f ; capa = c}} -> 
    ({ src = s ; tgt = d ; lbl = {flow = c-f;capa = c}} , { src = d ; tgt = s ; lbl = {flow = f ; capa = c}})

let convertGraph gr = gmap gr (fun lbl -> {flow=0;capa=lbl})

let edgeGraph (gr: fulkerson_graphs) = 
  e_fold gr (fun grb arc -> let (arc1, arc2)= createArcs arc in 
  let ngrb = add_arc grb arc1.src arc1.tgt arc1.lbl.flow in 
  add_arc ngrb arc2.src arc2.tgt arc2.lbl.flow ) (clone_nodes gr)

let grapheJoli gr = gmap gr (fun x -> string_of_int x.flow ^ "/" ^ string_of_int x.capa)

  (*
  gmap gr (
  fun arc -> (let (arc1,arc2) = createArcs arc in 
  
  let ngrb = add_arc (convertGraph gr) arc1.src arc1.tgt arc1.lbl.flow in
  
  add_arc ngrb arc2.src arc2.tgt arc2.lbl.flow)) *)

let dfs gr origin destination =
  let rec dfsAux o d acu =
    if (o = d) then Some acu (*should return acu...*)
    else 
      let listArcs = out_arcs gr origin in 
      let listArcsFiltered = List.filter (fun x -> List.mem o acu && x.lbl <> 0) listArcs in 
      let listNodesFiltered = List.map (fun x -> x.tgt) listArcsFiltered in
      if (listNodesFiltered = []) then None
      else List.find_opt (fun node -> match (dfsAux node d (o::acu)) with 
      | Some x -> true
      | None -> false) listNodesFiltered 
  in 
  dfsAux origin destination []