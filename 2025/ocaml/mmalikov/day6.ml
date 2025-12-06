let lines =
  In_channel.with_open_text "inputs/day6/full.txt" In_channel.input_all
  |> String.split_on_char '\n'

let number_lines, op_line =
  match List.rev lines with
  | last :: rev_rest -> (List.rev rev_rest, last)
  | [] -> failwith "empty input"

let words s = String.split_on_char ' ' s |> List.filter (( <> ) "")
let numbers = List.map (fun l -> List.map int_of_string (words l)) number_lines
let operations = words op_line

let rec transpose = function
  | [] | [] :: _ -> []
  | rows -> List.map List.hd rows :: transpose (List.map List.tl rows)

let calculate = function
  | "*", xs -> List.fold_left ( * ) 1 xs
  | "+", xs -> List.fold_left ( + ) 0 xs
  | op, _ -> failwith ("unknown op: " ^ op)

let _part1 =
  List.combine operations (transpose numbers)
  |> List.map calculate |> List.fold_left ( + ) 0 |> string_of_int
  |> print_endline

let split sep list =
  List.fold_right
    (fun x acc ->
      match acc with
      | [] -> [ [ x ] ]
      | y :: ys -> if x = sep then [] :: acc else (x :: y) :: ys)
    list [ [] ]

let ( >> ) f g x = g (f x)

let rtl_numbers =
  number_lines
  |> List.map (String.to_seq >> List.of_seq)
  |> transpose
  |> List.map (List.to_seq >> String.of_seq >> String.trim)
  |> split ""
  |> List.map (List.map int_of_string)

let _part2 =
  List.combine operations rtl_numbers
  |> List.map calculate |> List.fold_left ( + ) 0 |> string_of_int
  |> print_endline
