let lines =
  In_channel.with_open_text "inputs/day7/sample.txt" In_channel.input_all
  |> String.split_on_char '\n'

let start_pos = String.index_opt (List.hd lines) 'S' |> Option.get

module Iset = Set.Make (Int)
module Imap = Map.Make (Int)

let find_splitters line =
  line |> String.to_seq |> List.of_seq
  |> List.mapi (fun i elem -> (i, elem))
  |> List.filter_map (fun p ->
      match p with i, elem -> if elem = '^' then Some i else None)
  |> Iset.of_list

let upd key value m =
  Imap.update key
    (function None -> Some value | Some old -> Some (old + value))
    m

let split beams splitters =
  let rec iter beams splitters new_beams n_splits =
    match beams with
    | [] -> (new_beams, n_splits)
    | (beam_index, n_timelines) :: rest ->
        if Iset.mem beam_index splitters then
          let updated_beams =
            upd (beam_index + 1) n_timelines new_beams
            |> upd (beam_index - 1) n_timelines
          in
          iter rest splitters updated_beams (n_splits + 1)
        else iter rest splitters (upd beam_index n_timelines new_beams) n_splits
  in
  iter (Imap.to_list beams) splitters Imap.empty 0

let rec iter lines_remaining beams n_splits =
  match lines_remaining with
  | [] -> (n_splits, beams)
  | line :: rest ->
      let new_beams, n_new_splits = split beams (find_splitters line) in
      iter rest new_beams (n_splits + n_new_splits)

let n_splits, beams = iter (List.drop 1 lines) (Imap.singleton start_pos 1) 0
let () = n_splits |> string_of_int |> print_endline

let () =
  Imap.fold (fun _ v acc -> v + acc) beams 0 |> string_of_int |> print_endline
