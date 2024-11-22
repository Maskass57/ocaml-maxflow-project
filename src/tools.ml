(* Yes, we have to repeat open Graph. *)
open Graph

(* assert false is of type ∀α.α, so the type-checker is happy. *)
let clone_nodes (gr:'a graph) = n_fold gr new_node empty_graph
let gmap gr f = e_fold gr (fun grb arc -> new_arc grb {src=arc.src; tgt=arc.tgt;lbl=f arc.lbl}) (clone_nodes gr)
    
(*Even if the specified prototype on website is with int lbl, we chose 
  to implement the function in order to allow a polymorphic lbl*)
let  add_arc gr src tgt lbl = new_arc gr {src=src; tgt=tgt;lbl=lbl}
