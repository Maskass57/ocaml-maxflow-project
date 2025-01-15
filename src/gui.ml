open GMain
open Graph 
open FulkersonCost
let infile = Sys.argv.(1)
let read_line line hashtbl =
  try 
    (*print_endline ("Input line: " ^ line);*)
    Scanf.sscanf line "n %s %d" (fun name id -> Hashtbl.add hashtbl id name)
  with e ->
    Printf.printf "Cannot read node in line - %s:\n%s\n%!" (Printexc.to_string e) line ;
    failwith "read_line"

let find_name_id path =
  let infile = open_in path in
  let table = Hashtbl.create 100 in
  (* Read all lines until end of file. *)
  let rec loop () =
    try
      let line = input_line infile in

      (* Remove leading and trailing spaces. *)
      let line = String.trim line in

      let _ =
        (* Ignore empty lines *)
        if line = "" then ()

        (* The first character of a line determines its content : n or a. *)
        else match line.[0] with
          | 'n' -> read_line line table
          | 'a' -> ()

          (* It should be a comment, otherwise we complain. *)
          | _ -> ()
      in      
      loop ()

    with End_of_file -> () (* Done *)
  in

  loop ();
  close_in infile ;
  table

let obtain_peopleID_sportID (gr:fulkerson_label_cost graph) = 
  e_fold gr (fun acu arc -> 
      if (arc.lbl.flow = 1 && (arc.src <> 1000) && (arc.src <> 1001) && (arc.tgt <> 1000) && (arc.tgt <> 1001)) then
        (arc.src,arc.tgt)::acu
      else 
        acu) []

let obtain_name id hashtbl =
  Hashtbl.find hashtbl id

let get_first_val = function 
  | [] -> (0,0)
  | (flow,capa)::_ -> (flow,capa)

let obtain_sport_flow_capa (gr:fulkerson_label_cost graph) id = 
  let list = e_fold gr (fun acu arc -> 
      if (arc.src = id && arc.tgt = 1001) then
        (arc.lbl.flow,arc.lbl.capa)::acu
      else 
        acu) [] in 
  get_first_val list

let print_flow_capa (flow,capa) =
  string_of_int flow ^ "/" ^string_of_int capa 

(* Displays a textual result in a window *)
let gui_display gr =  
  let path = infile in
  let _ = GMain.init () in
  let window = GWindow.window ~title:"Résultat Ford-Fulkerson" ~border_width:10 ~width:600 ~height:400 () in
  let hbox = GPack.hbox ~packing:window#add () in
  let vbox_left = GPack.vbox ~packing:hbox#add () in

  let button = GButton.button ~label:"Fermer" ~packing:vbox_left#pack () in
  button#connect#clicked ~callback:Main.quit |> ignore;

  let hashtbl = find_name_id path in
  let ids = obtain_peopleID_sportID gr in 

  List.iter(fun (idName,idSport) -> 
      let text_to_display = obtain_name idName hashtbl  ^ " a été attribué au sport : "  ^ obtain_name idSport hashtbl  in 
      let text_view = GText.view ~packing:vbox_left#pack () in
      text_view#buffer#set_text text_to_display) ids;

  let vbox_right = GPack.vbox ~packing:hbox#pack ~width:200 ~spacing:30 () in
  let _label1 = GMisc.label ~text:("Cout total : " ^ string_of_int (getCostGraph gr)) ~packing:vbox_right#pack () in
  let listeSports = List.fold_left (fun acu (_,idSport) -> 
      let name_sport = Hashtbl.find hashtbl idSport in 
      if (List.mem (name_sport,idSport) acu) then
        acu
      else 
        (name_sport,idSport)::acu
    ) [] ids in
  let _label2 = GMisc.label ~text:("Résultat des sports: \n"
                                   ^ List.fold_left (fun acu (nomSport,idSport) -> acu ^ "\n" ^ nomSport ^ " " ^ print_flow_capa (obtain_sport_flow_capa gr idSport)) "" listeSports) ~packing:vbox_right#pack () in

  window#show ();
  GMain.main ();

