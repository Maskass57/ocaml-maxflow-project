open Graph

type fulkerson_label = {flow : int; capa : int}
type fulkerson_graphs = fulkerson_label graph
type node = id

val edgeGraph: fulkerson_graphs -> int graph
val convertGraph: id graph -> fulkerson_graphs
val grapheJoli: fulkerson_label graph -> string graph

val unOption: (id list * int) option -> (id list * int)
val dfs: int graph -> id -> id -> (id list * int) option
val get_list: (id list * int) option -> id list
val get_min: (id list * int) option -> int

val updateEdgeGraph: int graph -> (id list * int) -> int graph
val unEdgeGraph: fulkerson_graphs -> int graph -> int graph
val fordFulkerson: int graph -> id -> id -> int graph
(*
val createArcs: fulkerson_label Graph.arc ->  (fulkerson_label arc , fulkerson_label arc)*)