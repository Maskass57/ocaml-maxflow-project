open Graph

type fulkerson_label = {flow : int; capa : int}
type fulkerson_graphs = fulkerson_label graph
type node = id

val edgeGraph: fulkerson_graphs -> int graph
val convertGraph: id graph -> fulkerson_graphs
val grapheJoli: fulkerson_label graph -> string graph

val dfs: id graph -> id -> id -> id list option
val dfsConvert: id list option -> id list
(*
val createArcs: fulkerson_label Graph.arc ->  (fulkerson_label arc , fulkerson_label arc)*)