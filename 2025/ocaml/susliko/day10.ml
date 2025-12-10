open Lp
module ISet = Set.Make (Int)
module SSet = Set.Make (String)

type _machine = { enabled : string; buttons : ISet.t list; joltage : int list }

let data =
  let unbrace s = String.sub s 1 (String.length s - 2) in
  let parse s =
    unbrace s |> String.split_on_char ',' |> List.map int_of_string
  in
  let parse_set s = parse s |> ISet.of_list in

  Utils.read_input 10
  |> List.filter (( <> ) "")
  |> List.map (fun line ->
      match line |> String.split_on_char ' ' |> List.filter (( <> ) "") with
      | [] -> failwith "empty machine list"
      | machine :: rest -> (
          match List.rev rest with
          | [] -> failwith "empty button list"
          | joltage :: buttons ->
              {
                enabled = unbrace machine;
                buttons = List.rev_map parse_set buttons;
                joltage = parse joltage;
              }))

let press state button =
  state |> String.to_seqi
  |> Seq.map (fun (i, c) ->
      if ISet.mem i button then match c with '.' -> '#' | _ -> '.' else c)
  |> String.of_seq

let enable machine =
  let rec go i states =
    if SSet.mem machine.enabled states then i
    else
      let i' = i + 1 in
      let states' =
        states |> SSet.to_list
        |> List.map (fun state ->
            machine.buttons |> List.map (fun button -> press state button))
        |> List.fold_left
             (fun acc states -> SSet.of_list states |> SSet.union acc)
             SSet.empty
      in
      (* states' |> SSet.to_list |> Utils.print_str_list; *)
      go i' states'
  in
  let first_state = String.make (String.length machine.enabled) '.' in
  go 0 @@ SSet.of_list [ first_state ]

let solve_linear num_vars equations =
  let vars =
    List.init num_vars (fun i ->
        var ~integer:true ~lb:0. (Printf.sprintf "x%d" i))
  in

  let objective =
    match vars with
    | [] -> failwith "No variables"
    | v :: rest -> List.fold_left (fun acc v -> acc ++ v) v rest
  in

  let constraints =
    equations
    |> List.map (fun (inds, rhs) ->
        let left_side =
          match inds with
          | [] -> failwith "Empty equation"
          | first_idx :: rest ->
              let init = List.nth vars first_idx in
              List.fold_left
                (fun acc var_idx -> acc ++ List.nth vars var_idx)
                init rest
        in
        left_side =~ c (float_of_int rhs))
  in

  let problem = make (minimize objective) constraints in

  match Lp_glpk.solve problem with
  | Ok (_, solution) ->
      let values =
        List.map (fun v -> int_of_float (PMap.find v solution)) vars
      in
      Some values
  | Error _ -> None

let power machine =
  let equations =
    machine.joltage
    |> List.mapi (fun butind j ->
        let inds =
          machine.buttons
          |> List.mapi (fun i but -> (i, but))
          |> List.filter_map (fun (i, but) ->
              if ISet.mem butind but then Some i else None)
        in
        (inds, j))
  in
  let num_vars = List.length machine.buttons in
  let solution = solve_linear num_vars equations in
  let coeffs = Option.value ~default:[] solution in
  coeffs |> List.fold_left ( + ) 0

let () =
  let enabled = data |> List.map enable in
  let part1 = enabled |> List.fold_left ( + ) 0 in
  let powered = data |> List.map power in
  let part2 = powered |> List.fold_left ( + ) 0 in
  print_int part1;
  print_endline "";
  print_int part2
