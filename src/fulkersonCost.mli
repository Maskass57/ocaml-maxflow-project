open Tools
open Graph
open Gfile

type input_graph = {capa:id;cost:id}

type fulkerson_label_cost = {flow : id; capa : id; cost: id}
type fulkerson_graphs_cost = fulkerson_label_cost graph
type node = id
type edgegraph_label = {flow:id;cost:id}
type edgegraph_cost = edgegraph_label graph

val convertGraph_Cost: input_graph -> fulkerson_label_cost