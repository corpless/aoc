module Pset = Set.Make(struct type t = int * int let compare = compare end)

let init_rolls =
In_channel.with_open_text "inputs/day4/full.txt" In_channel.input_all
|> String.split_on_char '\n' |> List.map String.to_seq |> List.map List.of_seq
|> List.mapi (fun i row -> List.mapi (fun j elem -> if elem = '@' then [(i, j)] else []) row |> List.flatten)
|> List.flatten
|> Pset.of_list

let neighbours p =
  let x = fst p and y = snd p in
  [(x-1, y-1); (x-1, y); (x-1, y+1); (x, y-1); (x, y+1); (x+1, y-1); (x+1, y); (x+1, y+1)]

let count_neighbours rolls p  = neighbours p |> List.filter(fun n -> Pset.mem n rolls) |> List.length

let get_accessible rolls = rolls |> Pset.to_list |> List.filter (fun p -> (count_neighbours rolls p) < 4)

let () = (get_accessible init_rolls) |> List.length |> string_of_int |> print_endline

let rec iter rolls res = 
  let new_rolls = get_accessible rolls |> Pset.of_list in
  if Pset.is_empty new_rolls then res 
  else iter (Pset.diff rolls new_rolls) (res + (Pset.cardinal new_rolls))

let () = iter init_rolls 0 |> string_of_int |> print_endline
