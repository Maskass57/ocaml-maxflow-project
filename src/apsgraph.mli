open Graph
open Gfile

val read_comment: 'a -> string -> 'a
val read_node_aps: 'a graph -> string -> 'a graph
val read_arc_aps: id graph -> string -> id graph
val partition_nodes: 'a graph -> id * id list * id list * id
val ensure: 'a graph -> id -> 'a graph
val from_file_aps: path -> int graph
val add_origin_destination: int graph -> int graph
val exportAPS: path -> string graph -> unit