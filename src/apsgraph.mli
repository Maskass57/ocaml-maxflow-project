open Graph
open Gfile

val from_file_aps: path -> int graph
val add_origin_destination: int graph -> int graph
val exportAPS: path -> string graph -> unit
val ensure: 'a graph -> id -> 'a graph
val read_comment: 'a -> string -> 'a