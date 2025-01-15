open Graph
open Gfile

type input_label = {capa:id;cost:id}
type fulkerson_label_cost = {flow : id; capa : id; cost: id}

val fordFulkerson: input_label graph -> id -> id -> (fulkerson_label_cost graph * int)
val grapheJoli: fulkerson_label_cost graph -> path graph
val getCostGraph: fulkerson_label_cost graph -> int