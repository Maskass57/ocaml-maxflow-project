open Tools
open Graph
open Gfile

type fulkerson_label = {flow : id; capa : id}

(**
    Create 2 arcs from the input arc.
    @param arc: fulkerson_label arc.
    @return : (fulkerson_label arc * fulkerson_label arc).
*)
let createArcs = function  | {src = s ; tgt = d ; lbl = {flow = f ; capa = c}} -> 
  ({ src = s ; tgt = d ; lbl = {flow = c-f;capa = c}} , { src = d ; tgt = s ; lbl = {flow = f ; capa = c}})

(**
    Convert an int graph into a fulkerson_label graph.
    @param gr : int graph.
    @return : fulkerson_label graph.
*)
let convertGraph gr = gmap gr (fun lbl -> {flow=0;capa=lbl})

(**
    Convert a fulkerson_label graph into a edge graph (int graph).
    @param gr : fulkerson_label graph.
    @return : int graph.
*)
let edgeGraph gr = 
  e_fold gr (fun grb arc -> let (arc1, arc2)= createArcs arc in 
              let ngrb = add_arc grb arc1.src arc1.tgt arc1.lbl.flow in 
              add_arc ngrb arc2.src arc2.tgt arc2.lbl.flow ) (clone_nodes gr)

(**
    Maps a fulkerson_label graph into a path graph (String graph).
    @param gr : fulkerson_label graph.
    @return : path graph.
*)
let grapheJoli gr = gmap gr (fun x -> string_of_int x.flow ^ "/" ^ string_of_int x.capa)

(**
    Performs dfs path finding on a graph with a given origin and destination node.
    @param gr : edge graph (int graph).
    @param origin : id (int).
    @param destination : id (int).
    @return : (id list (the path) * int (max flow over the path)).
*)
let dfs gr origin destination =
  let rec dfsAux o d acu =
    let (lst,minimu)=acu in
    if (o = d) then Some ((List.rev (d::lst), minimu))
    else 
      let listArcs = out_arcs gr o in 
      let listArcsFiltered = List.filter (fun x -> not(List.mem o lst) && x.lbl <> 0) listArcs in 
      let listNodesFiltered = List.map (fun x -> x.tgt) listArcsFiltered in
      let rec try_nodes nodes =
        match nodes with
        | [] -> None
        | node :: rest -> (
            match dfsAux node d ((o :: lst),min minimu ((unOption (find_arc gr o node)).lbl)) with
            | Some path -> Some path
            | None -> try_nodes rest 
          )
      in try_nodes listNodesFiltered
  in 
  dfsAux origin destination ([], max_int)

(**
    Update the edge graph (int graph) thanks to the path found. 
    @param gr : edge graph (int graph).
    @param dsfResult : (int list * int ).
    @return : edge graph (int graph).
*)
let rec updateEdgeGraph gr dfsResult = 
  let (lst,inc) = dfsResult in 
  match lst with
  | x::y::rest -> let gr1 = add_arc gr x y (-inc) in updateEdgeGraph (add_arc gr1 y x inc) ((y::rest),inc)
  | _x::[] -> gr
  | [] -> gr


(**
    Convert a edge graph (int graph) into a fulkerson_label graph.
    @param startGraph: fulkerson_label graph.
    @param eGraph: edge graph (int graph).
    @return : fulkerson_label graph.
*)
let unEdgeGraph startGraph eGraph =
  e_fold startGraph (fun acu x  -> 
      let capaInverse = match find_arc startGraph x.tgt x.src with
        | Some arc -> arc.lbl.capa
        | None -> 0
      in 
      let newVal = (unOption (find_arc eGraph x.tgt x.src)).lbl - capaInverse in 
      if (newVal >= 0) 
      then new_arc acu {src=x.src; tgt=x.tgt; lbl={flow=newVal; capa=x.lbl.capa}}
      else new_arc acu {src=x.src; tgt=x.tgt; lbl={flow=0; capa=x.lbl.capa}}) (clone_nodes startGraph)

(**
    Fulkerson implementation.
    @param gr : input graph (int graph).
    @param origin : id (int).
    @param destination : id (int).
    @return : fulkerson_label graph.
*)
let fordFulkerson gr origin destination =
  let fulkerson = convertGraph gr in 
  let eGraph = edgeGraph fulkerson in

  let mappedEGraph = gmap eGraph (fun x -> string_of_int x) in
  export ("./test.dot") mappedEGraph;

  let rec fordFulkersonAux gr1 i= 
    let temp = unEdgeGraph fulkerson gr1 in 
    let joli = grapheJoli temp in
    export ("./" ^ (string_of_int i) ^ ".dot") joli;
    match dfs gr1 origin destination with
    | None -> gr1
    | Some (lst, inc) -> 

      Printf.printf "Path found: [%s] and min: %s\n"
        (String.concat " -> " (List.map string_of_int lst)) (string_of_int (inc));

      if(lst=[]) then gr1 
      else fordFulkersonAux (updateEdgeGraph gr1 (lst,inc)) (i+1) 
  in
  unEdgeGraph fulkerson (fordFulkersonAux eGraph 0)






