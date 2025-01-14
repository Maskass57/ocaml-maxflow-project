open GMain

(* Displays a textual result in a window *)
let gui_display result =
  let _ = GMain.init () in

  let window = GWindow.window ~title:"Résultat Ford-Fulkerson" ~border_width:10 () in
  let vbox = GPack.vbox ~packing:window#add () in

  let text_view = GText.view ~packing:vbox#pack () in
  text_view#buffer#set_text result;

  let button = GButton.button ~label:"Fermer" ~packing:vbox#pack () in
  button#connect#clicked ~callback:Main.quit |> ignore;

  window#show ();
  Main.main ()
