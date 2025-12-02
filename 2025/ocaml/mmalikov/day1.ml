let text = In_channel.with_open_text "inputs/day1/full.txt" In_channel.input_all
let lines = String.split_on_char '\n' text

let parse_rotation s =
  let sign =
    match s.[0] with
    | 'R' -> 1
    | 'L' -> -1
    | _ -> raise (Invalid_argument "parsing error!")
  and value = int_of_string (String.sub s 1 (String.length s - 1)) in
  sign * value

let rotations = List.map parse_rotation lines

let count_states predicate =
  let f acc r =
    match acc with
    | pos, cnt ->
        let new_pos = (((pos + r) mod 100) + 100) mod 100 in
        (new_pos, cnt + predicate pos new_pos r)
  in
  let final_state = List.fold_left f (50, 0) rotations in
  snd final_state

let _part1 =
  string_of_int
    (count_states (fun _pos new_pos _r -> if new_pos == 0 then 1 else 0))

let part2_predicate pos _new_pos r =
  let full_rotations = Int.abs r / 100 in
  let remainder = r mod 100 in
  let crossed_zero =
    (pos + remainder >= 100 || pos + remainder <= 0) && pos != 0
  in
  full_rotations + if crossed_zero then 1 else 0

let () = print_endline (string_of_int (count_states part2_predicate))
