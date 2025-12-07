let prepare (lines : string list) =
  let rec group acc chars =
    let left = Seq.length chars in
    if left = 0 then List.rev acc
    else
      let chars' =
        chars |> Seq.drop_while (fun (_, el) -> el = ' ' || el == '\n')
      in
      let arg =
        chars' |> Seq.take_while (fun (_, el) -> el <> ' ') |> Array.of_seq
      in
      if Array.length arg = 0 then List.rev acc
      else group (arg :: acc) (Seq.drop (Array.length arg) chars')
  in
  match List.rev lines with
  | signs :: rev_args ->
      let args =
        rev_args
        |> List.map (fun line ->
            String.to_seqi line |> group [] |> Array.of_list)
        |> List.rev
      in
      let signs =
        String.split_on_char ' ' signs
        |> List.filter (( <> ) "")
        |> Array.of_list
      in
      (args, signs)
  | _ -> failwith "haha"

let solve args signs calc_args =
  let w = args |> List.hd |> Array.length in
  List.init w (fun _ -> 0)
  |> List.mapi (fun i _ ->
      let a = args |> List.map (fun l -> l.(i)) |> calc_args in
      match String.trim signs.(i) with
      | "+" -> a |> List.fold_left ( + ) 0
      | "*" -> a |> List.fold_left ( * ) 1
      | _ -> failwith "wow")
  |> List.fold_left ( + ) 0

let part1_args (args : (int * char) array list) : int list =
  args
  |> List.map (fun x ->
      Array.map snd x |> Array.to_seq |> String.of_seq |> int_of_string)

let part2_args (args : (int * char) array list) : int list =
  Array.concat args |> Array.to_list |> Utils.group_by ~key:fst
  |> List.map (fun (_, chars) ->
      chars |> List.map snd |> List.to_seq |> String.of_seq |> int_of_string)

let () =
  let args, signs = prepare @@ Utils.read_sample 6 in
  solve args signs part1_args |> print_int;
  print_endline "";
  solve args signs part2_args |> print_int
