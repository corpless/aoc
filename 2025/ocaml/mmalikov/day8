let lines =
  In_channel.with_open_text "inputs/day8/full.txt" In_channel.input_all
  |> String.split_on_char '\n'

let positions =
  lines
  |> List.map (String.split_on_char ',')
  |> List.map (List.map int_of_string)
  |> List.mapi (fun i pos -> (i, pos))

let iter2 l = List.concat_map (fun a -> List.map (fun b -> (a, b)) l) l

let dist pos1 pos2 =
  match (pos1, pos2) with
  | [ a1; b1; c1 ], [ a2; b2; c2 ] ->
      ((a1 - a2) * (a1 - a2)) + ((b1 - b2) * (b1 - b2)) + ((c1 - c2) * (c1 - c2))
  | _ -> failwith "invalid positions"

let distances =
  positions |> iter2
  |> List.map (fun x ->
      match x with (i1, pos1), (i2, pos2) -> ((i1, i2), dist pos1 pos2))
  |> List.filter (fun x -> fst (fst x) > snd (fst x))
  |> List.sort (fun a b -> compare (snd a) (snd b))

type elem = { p : int; size : int }

module Imap = Map.Make (Int)

let rec find index set =
  let found = Imap.find index set in
  if found.p = index then found else find found.p set

let union set edge =
  match edge with
  | index1, index2 ->
      let root1 = find index1 set in
      let root2 = find index2 set in
      if root1.p = root2.p then set
      else
        let bigger_root, smaller_root =
          if root1.size > root2.size then (root1, root2) else (root2, root1)
        in
        let new_bigger =
          { p = bigger_root.p; size = bigger_root.size + smaller_root.size }
        in
        let new_smaller = { p = bigger_root.p; size = smaller_root.size } in
        set
        |> Imap.add bigger_root.p new_bigger
        |> Imap.add smaller_root.p new_smaller

let init_set =
  List.init (List.length positions) (fun i -> (i, { p = i; size = 1 }))
  |> Imap.of_list

let _part1 =
  distances |> List.take 1000 |> List.map fst
  |> List.fold_left union init_set
  |> Imap.to_list
  (*|> List.iter (fun x -> Printf.printf "parent=%i size=%i\n" (snd x).p (snd x).size) *)
  |> List.filter (fun x -> fst x = (snd x).p)
  |> List.map (fun x -> (snd x).size)
  |> List.sort compare |> List.rev |> List.take 3 |> List.fold_left ( * ) 1
  |> string_of_int |> print_endline

let x_pos index = List.hd (snd (List.nth positions index))

let rec part2_iter state remaining =
  match remaining with
    | [] -> failwith "reached end of input"
    | edge::rest -> 
      let new_state = union state edge in
      let new_state_size = new_state |> Imap.to_list |> List.map (fun x -> (snd x).size) |> List.fold_left max 0 in 
      if new_state_size = (List.length positions) then (x_pos (fst edge)) * (x_pos (snd edge))
      else part2_iter new_state rest

let () = distances |> List.map fst |> part2_iter init_set |> string_of_int |> print_endline
