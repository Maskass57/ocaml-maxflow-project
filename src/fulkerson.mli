open Graph

type fulkerson_label = {flow : int; capa : int}

val fordFulkerson: int graph -> id -> id -> fulkerson_label graph
val edgeGraph: fulkerson_label graph -> int graph
val grapheJoli: fulkerson_label graph -> string graph