open Graph
open FulkersonCost

val from_file_aps_cost: string -> input_label graph
val add_origin_destination_cost: input_label graph -> id -> input_label graph