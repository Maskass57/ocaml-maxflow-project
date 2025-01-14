open Graph
open FulkersonCost

val read_arc_cost: input_label graph -> string -> input_label graph
val from_file_aps_cost: string -> input_label graph
val add_origin_destination_cost: input_label graph -> id -> input_label graph