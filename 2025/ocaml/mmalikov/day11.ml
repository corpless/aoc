let lines =
  In_channel.with_open_text "inputs/day11/sample.txt" In_channel.input_all
  |> String.split_on_char '\n'

module Smap = Map.Make (String)

let parse_line s =
  match String.split_on_char ':' s with
  | [ v; rest ] ->
      let edges =
        String.sub rest 1 (String.length rest - 1) |> String.split_on_char ' '
      in
      (v, edges)
  | _ -> failwith "invalid string"

let graph = lines |> List.map parse_line |> Smap.of_list

module Make_bfs (M : Map.S) = struct
  let upd m kv =
    M.update (fst kv)
      (function None -> Some (snd kv) | Some old -> Some (old + snd kv))
      m

  let rec bfs final_state progress_states cur_paths exit_count =
    if M.is_empty cur_paths then exit_count
    else
      let new_paths =
        M.to_list cur_paths
        |> List.concat_map (function v, cnt ->
            progress_states v |> List.map (fun v2 -> (v2, cnt)))
      in
      let compressed_paths = List.fold_left upd M.empty new_paths in
      let new_exits =
        M.find_opt final_state compressed_paths |> Option.value ~default:0
      in
      bfs final_state progress_states compressed_paths (exit_count + new_exits)
end

module Bfs1 = Make_bfs (Smap)

let bfs1 =
  Bfs1.bfs "out" (fun v -> Smap.find_opt v graph |> Option.value ~default:[])

let () = bfs1 (Smap.singleton "you" 1) 0 |> string_of_int |> print_endline

module Emap = Map.Make (struct
  type t = string * bool * bool

  let compare = compare
end)

let progress_states2 = function
  | pos, vdac, vfft ->
      Smap.find_opt pos graph |> Option.value ~default:[]
      |> List.map (fun pos2 -> (pos2, vdac || pos = "dac", vfft || pos = "fft"))

module Bfs2 = Make_bfs (Emap)

let bfs2 = Bfs2.bfs ("out", true, true) progress_states2

let () =
  bfs2 (Emap.singleton ("svr", false, false) 1) 0
  |> string_of_int |> print_endline
