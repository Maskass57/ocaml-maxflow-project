open Graph
open Gfile

val read_comment: 'a -> string -> 'a
val read_node_aps: 'a graph -> string -> 'a graph
val ensure: 'a graph -> id -> 'a graph
val from_file_aps: path -> int graph
val add_origin_destination: id graph -> id graph
val exportAPS: path -> string graph -> unit