open Graph

type fulkerson_label = {flow : int; capa : int}
type fulkerson_graphs = fulkerson_label graph


val edgeGraph: fulkerson_graphs -> int graph
val convertGraph: id graph -> fulkerson_graphs 
(*
val createArcs: fulkerson_label Graph.arc ->  (fulkerson_label arc , fulkerson_label arc)*)