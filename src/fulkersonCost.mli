open Graph
open Gfile

type input_label = {capa:id;cost:id}
type input_graph =  input_label graph
type fulkerson_label_cost = {flow : id; capa : id; cost: id}
type fulkerson_graphs_cost = fulkerson_label_cost graph
type edgegraph_label = {flow:id;cost:id}
type edgegraph_cost = edgegraph_label graph
type 'a dijkstra_label = {cost: int; prev: 'a option; marked: bool}

val convertGraph_Cost: input_label graph -> fulkerson_label_cost graph
val fordFulkerson: input_label graph -> id -> id -> (fulkerson_label_cost graph * int)
val grapheJoli: fulkerson_graphs_cost -> path graph
val getCostGraph: fulkerson_graphs_cost -> id