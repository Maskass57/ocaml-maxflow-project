open Tools
open Graph
open Gfile

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

let unOption x = match x with
  | Some x -> x
  | None -> raise (Graph_error("No path found: get_arc")) (*ERREUR ICI*)

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
      (* Tentative avec find_opt
         if (listNodesFiltered = []) then None
         else List.find_opt (fun node -> match (dfsAux node d (o::acu)) with 
         | Some x -> true
         | None -> false) listNodesFiltered *)
  in 
  dfsAux origin destination ([], max_int)

let get_list = function 
  | Some (lst,_min) -> lst
  | None -> raise (Graph_error("No path found"))

let get_min = function
  | Some (_lst,min) -> min
  | None -> raise (Graph_error("No path found"))

let rec updateEdgeGraph gr dfsResult = 
  let (lst,inc) = dfsResult in 
  match lst with
  | x::y::rest -> let gr1 = add_arc gr x y (-inc) in updateEdgeGraph (add_arc gr1 y x inc) ((y::rest),inc)
  | _x::[] -> gr
  | [] -> gr


let getVal = function
  | Some x -> x
  | None -> raise (Graph_error("No path found"))
let unEdgeGraph startGraph eGraph =
  (*gmap startGraph (fun x -> let newVal = (getVal (find_arc eGraph x.tgt x.src)).lbl in {flow = newVal; capa = x.lbl.capa}  )*)
  e_fold startGraph (fun acu x  -> 
      let capaInverse = match find_arc startGraph x.tgt x.src with
        | Some arc -> arc.lbl.capa
        | None -> 0
      in 
      let newVal = (getVal (find_arc eGraph x.tgt x.src)).lbl - capaInverse in 
      if (newVal >= 0) 
      then new_arc acu {src=x.src; tgt=x.tgt; lbl={flow=newVal; capa=x.lbl.capa}}
      else new_arc acu {src=x.src; tgt=x.tgt; lbl={flow=0; capa=x.lbl.capa}}) (clone_nodes startGraph)

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






