open Graph
open Gfile

type input_label = {capa:id;cost:id}
type input_graph =  input_label graph
type fulkerson_label_cost = {flow : id; capa : id; cost: id}
type fulkerson_graphs_cost = fulkerson_label_cost graph
type edgegraph_label = {flow:id;cost:id}
type edgegraph_cost = edgegraph_label graph
type 'a dijkstra_label = {cost: int; prev: 'a option; marked: bool}

val createArcs_cost: fulkerson_label_cost arc -> fulkerson_label_cost arc * fulkerson_label_cost arc
val convertGraph_Cost: input_label graph -> fulkerson_label_cost graph
val add_arc_cost: edgegraph_label graph -> id -> id -> edgegraph_label -> edgegraph_label graph
val edgeGraph_cost: fulkerson_graphs_cost -> edgegraph_label graph
val count_nodes: 'a graph -> id
val initialize_dijkstra_hashtbl: 'a graph -> id -> (id, 'b dijkstra_label) Hashtbl.t
val find_min_node: ('a, 'b dijkstra_label) Hashtbl.t -> 'a option * id
val update_neighbours: edgegraph_label graph -> (id, id dijkstra_label) Hashtbl.t -> id * id -> unit
val fordFulkerson: input_label graph -> id -> id -> (fulkerson_label_cost graph * int)
val grapheJoli: fulkerson_graphs_cost -> path graph
val getCostGraph: fulkerson_graphs_cost -> id