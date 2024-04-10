WeChat: cstutorcs
QQ: 749389476
Email: tutorcs@163.com
open OUnit2
open Gameengine

(********************************************)
(*                Game Setup                *)
(********************************************)

(** The root of the project. The ..s get us out of the test and build directories.
    This allows us to get to the example_games directory *)
let root = Sys.getcwd () ^ "/../example_games/"

let file_from_root fn = root ^ fn

let one_room_game = 
  match State.from_file (file_from_root "one_room.json") with
  | Ok g -> g
  | Error s -> failwith ("Error Parsing the One-Room Game: " ^ s)

let org_init = State.init_state one_room_game

let two_room_game = 
  match State.from_file (file_from_root "two_rooms.json") with
  | Ok g -> g
  | Error s -> failwith ("Error Parsing the Two-Room Game: " ^ s)

let trg_init = State.init_state two_room_game

(*
let small_circle_game =
  match State.from_file (file_from_root "small_circle.json") with
  | Ok g -> g
  | Error s -> failwith ("Error Parsing the Small-Circle Game: " ^ s)

let scg_init = State.init_state small_circle_game
*)

(*******************************************)
(*        Testing Utility Functions        *)
(*******************************************)

let string_res_printer = function
| Ok s -> "Ok: " ^ s
| Error s -> "Error: " ^ s

(* let int_res_printer = function
| Ok i -> "Ok: " ^ (string_of_int i)
| Error s -> "Error: " ^ s *)

let int_list_printer_int x xs = 
  List.fold_left (fun s y -> s ^ "; " ^ (string_of_int y)) (string_of_int x) xs

let int_list_printer = function
| [] -> "[]"
| (x :: xs) -> "[" ^ int_list_printer_int x xs ^ "]"

let option_printer (p : 'a -> string) = function
| Some x -> "Some: " ^ p x
| None -> "None"

let assert_string_eq s1 s2 =
  (fun _ -> assert_equal s1 s2 ~printer:(fun x -> x))

let assert_bool_eq b1 b2 =
  (fun _ -> assert_equal b1 b2 ~printer:string_of_bool)

let assert_int_eq x y =
  (fun _ -> assert_equal x y ~printer:string_of_int)

let assert_string_res_eq x y =
  (fun _ -> assert_equal x y ~printer:string_res_printer)


(* let assert_int_res_eq x y =
  (fun _ -> assert_equal x y ~printer:int_res_printer)
 *)

let assert_int_list_eq x y =
  (fun _ -> assert_equal x y ~printer:int_list_printer)

let assert_option_int_list_eq x y =
  (fun _ -> assert_equal x y ~printer:(option_printer int_list_printer))

let assert_ok x =
  (fun _ -> match x with | Ok _ -> assert_bool "" true | Error e -> assert_failure ("Expected Ok, got (Error " ^ e ^")"))

let play_with_errors g prev_st cmd_maybe = 
  match prev_st with
  | Error e -> Error ("Previous state error: " ^ e)
  | Ok (st, msg) ->
    begin match cmd_maybe with
    | Error e -> Error ("Command parse error: " ^ e)
    | Ok cmd -> 
      let (st', msg') = Command.run_command g st cmd in
      Ok (st', msg ^ "\n" ^ msg')
    end 

(***********************************************)
(*               One-room tests                *)
(***********************************************)

let one_room_parse = "One Room Parsing Tests" >:::
[
  "Winning message" >:: (assert_string_eq 
                          ("You won!") 
                          (State.win_msg one_room_game));
  "Starting Room" >:: (assert_int_eq 0 (State.cur_room org_init));
  "Describe Room" >:: (assert_string_res_eq 
                        (Ok "The only room in this adventure.")
                        (State.desc_room 0 one_room_game org_init));
  "Exits" >:: (assert_option_int_list_eq 
                (Some []) (State.exits 0 one_room_game));
  "Nonexistant Exits" >:: (assert_option_int_list_eq
                            None (State.exits 1 one_room_game));
  "You've already won" >:: (assert_bool_eq true (State.has_won one_room_game org_init))
]

(***********************************************)
(*               Two-room tests                *)
(***********************************************)

(* Play the game *)

let go_other_cmd = Command.parse two_room_game "go other"
let go_first_cmd = Command.parse two_room_game "go first"

let turn1 = 
  match go_other_cmd with
  | Ok cmd -> Ok (Command.run_command two_room_game trg_init cmd)
  | Error e -> Error ("Command parse error: " ^ e)

let turn2 = play_with_errors two_room_game turn1 go_first_cmd

let turn3 = play_with_errors two_room_game turn2 go_other_cmd

let two_room_play = "Two-Room Play Tests" >:::
[
  "Parse \"go other\"" >:: (assert_ok go_other_cmd);
  "Parse \"go first\"" >:: (assert_ok go_other_cmd);
  "Play turn 1" >:: (assert_ok turn1);
  "Play turn 2" >:: (assert_ok turn2);
  "Play turn 3" >:: (assert_ok turn3)
] @
match turn1 with
| Error _ -> [] (* We already have detected this if it's a problem! *)
| Ok (st1, _) -> 
  [
    "In other room" >:: (assert_int_eq 1 (State.cur_room st1));
    "We won" >:: (assert_bool_eq true (State.has_won two_room_game st1));
    "We have one point" >:: (assert_int_eq 1 (State.cur_score st1));
    "Empty inventory" >:: (assert_int_list_eq [] (State.inventory st1));
  ] @
  match turn2 with
  | Error _ -> [] (* Already tested *)
  | Ok (st2, _) -> (* Importantly, we didn't take away the loss *)
    [
      "In first room" >:: (assert_int_eq 0 (State.cur_room st2));
      "We won" >:: (assert_bool_eq true (State.has_won two_room_game st2));
      "We have one point" >:: (assert_int_eq 1 (State.cur_score st2));
      "Empty inventory" >:: (assert_int_list_eq [] (State.inventory st2))
    ] @
    match turn3 with
    | Error _ -> []
    | Ok (st3, _) -> (* Importantly, we haven't added more points! *)
      [
        "In other room" >:: (assert_int_eq 1 (State.cur_room st3));
        "We won" >:: (assert_bool_eq true (State.has_won two_room_game st3));
        "We have one point" >:: (assert_int_eq 1 (State.cur_score st3));
        "Empty inventory" >:: (assert_int_list_eq [] (State.inventory st3));
      ]

(*******************************************************************************************)
(*                                      Run the Tests                                      *)
(*******************************************************************************************)

let _ = 
  run_test_tt_main one_room_parse;
  run_test_tt_main two_room_play