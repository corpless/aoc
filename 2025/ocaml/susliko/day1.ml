let parse s =
  let rest : int = String.sub s 1 (String.length s - 1) |> int_of_string in
  match s.[0] with
  | 'L' -> -rest
  | 'R' -> rest
  | other -> failwith (Printf.sprintf "%c is not L or R" other)

(* let rec part1 pos res shifts = *)
(*   match shifts with *)
(*   | [] -> res *)
(*   | s :: others -> *)
(*       let new_pos = (pos + s) mod 100 in *)
(*       let new_pos = if new_pos < 0 then new_pos + 100 else new_pos in *)
(*       let new_res = if new_pos = 0 then res + 1 else res in *)
(*       print_int new_pos; *)
(*       print_newline (); *)
(*       part1 new_pos new_res others *)
(**)
let rec part2 pos res shifts =
  match shifts with
  | [] -> res
  | s :: others ->
      let rounds = abs s / 100 in
      let remainder = s mod 100 in
      let new_pos' = pos + remainder in
      let new_pos = (new_pos' + 100) mod 100 in
      let add_round =
        if pos <> 0 && (new_pos' <= 0 || new_pos' >= 100) then 1 else 0
      in
      let new_res = res + rounds + add_round in
      part2 new_pos new_res others

let () =
  let start = 50 in
  (* let input = Utils.read_sample 1 in *)
  let input = Utils.read_input 1 in
  (* List.map parse input |> part1 start 0 |> print_int *)
  List.map parse input |> part2 start 0 |> print_int
