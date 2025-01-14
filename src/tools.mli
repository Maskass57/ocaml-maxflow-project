open Graph

val red: string
val green: string
val yellow: string
val reset: string
val bold: string
val clone_nodes: 'a graph -> 'b graph
val gmap: 'a graph -> ('a -> 'b) -> 'b graph
val add_arc: int graph -> id -> id -> int -> int graph
val unOption: 'a option -> 'a