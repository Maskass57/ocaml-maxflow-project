open Graph

type fulkerson_label = {flow : int; capa : int}
type fulkerson_graphs = fulkerson_label graph
type node = id

val createArcs: fulkerson_label arc -> fulkerson_label arc * fulkerson_label arc
val convertGraph: node graph -> fulkerson_label graph
val edgeGraph: fulkerson_graphs -> int graph
val grapheJoli: fulkerson_label graph -> string graph

val dfs: int graph -> id -> id -> (id list * int) option
val get_list: (id list * int) option -> id list
val get_min: (id list * int) option -> int

val updateEdgeGraph: int graph -> (id list * int) -> int graph
val getVal: 'a option -> 'a
val unEdgeGraph: fulkerson_graphs -> int graph -> fulkerson_graphs
val fordFulkerson: int graph -> id -> id -> fulkerson_graphs
(*
val createArcs: fulkerson_label Graph.arc ->  (fulkerson_label arc , fulkerson_label arc)*)