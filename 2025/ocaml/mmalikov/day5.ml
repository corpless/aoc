let lines = In_channel.with_open_text "inputs/day5/full.txt" In_channel.input_all
|> String.split_on_char '\n'

let empty_index = List.find_index (fun l -> String.length l == 0) lines |> Option.get
let ranges = List.take (empty_index) lines 
|> List.map (String.split_on_char '-')
|> List.map (fun x -> match x with [a;b] -> (int_of_string a, int_of_string b) | _ -> failwith "invalid range")

let point_in_range point range = point >= (fst range) && point <= (snd range)

let values = List.drop (empty_index + 1) lines
|> List.map int_of_string
|> List.filter (fun item -> List.exists (point_in_range item) ranges)

let () = values |> List.length |> string_of_int |> print_endline

module Pset = Set.Make(struct type t = int * int let compare = compare end)

let intervals_intersect a b = (point_in_range (fst a) b) || (point_in_range (snd a) b)
let rec merge_intersecting res remaining = match remaining with 
  | [] -> res
  | x::xs -> 
    let new_res = ((min (fst res) (fst x)), (max (snd res) (snd x))) in
    merge_intersecting new_res xs

let rec combine_intervals merged remaining = match remaining with
  | [] -> merged
  | cur_interval::tail -> 
  let to_be_removed = Pset.filter (intervals_intersect cur_interval) merged in
  if Pset.is_empty to_be_removed then
    combine_intervals (Pset.add cur_interval merged) tail
  else
    let new_interval = merge_intersecting cur_interval (Pset.to_list to_be_removed) in
    combine_intervals (Pset.diff merged to_be_removed) (new_interval::tail)

let c = combine_intervals Pset.empty ranges 

let () = c |> Pset.to_list |> List.map (fun p -> (snd p) - (fst p) + 1) 
|> List.fold_left (+) 0 |> string_of_int |> print_endline
