module ISet = Set.Make (Int)
module IISet = Set.Make (ISet)
module IMap = Map.Make (Int)

type point = { x : float; y : float; z : float }

let points =
  Utils.read_input 8
  |> List.filter (( <> ) "")
  |> List.map (fun l ->
      let coords =
        String.split_on_char ',' l
        |> List.filter (( <> ) "")
        |> List.map (fun x -> float_of_string x)
      in
      match coords with
      | [ x; y; z ] -> { x; y; z }
      | _ -> failwith @@ Printf.sprintf "Line '%s' is bad" l)
  |> Array.of_list

let distance p1 p2 =
  let dx = p1.x -. p2.x and dy = p1.y -. p2.y and dz = p1.z -. p2.z in
  (dx *. dx) +. (dy *. dy) +. (dz *. dz)

let dfs graph s =
  let rec go v visited =
    if ISet.mem v visited then visited
    else
      let visited' = ISet.add v visited in
      let nbs = IMap.find_opt v graph |> Option.value ~default:ISet.empty in
      ISet.fold (fun nb vis -> go nb vis) nbs visited'
  in
  go s ISet.empty

let add_edge i j graph =
  let add i j graph =
    graph
    |> IMap.update i (fun x ->
        let edges = Option.value x ~default:ISet.empty in
        Some (ISet.add j edges))
  in
  add i j graph |> add j i

let all_distances points =
  let n = Array.length points in
  let dists = ref [] in
  for i = 0 to n - 2 do
    for j = i + 1 to n - 1 do
      let d = distance points.(i) points.(j) in
      dists := (i, j, d) :: !dists
    done
  done;
  List.sort (fun (_, _, d1) (_, _, d2) -> Float.compare d1 d2) !dists

let all_dists = all_distances points

let connect graph n =
  let rec go graph edges_added remaining_dists last_edge =
    if edges_added >= n then (graph, last_edge)
    else
      match remaining_dists with
      | [] -> (graph, last_edge)
      | (i, j, _) :: rest ->
          let has_edge =
            IMap.find_opt i graph
            |> Option.value ~default:ISet.empty
            |> ISet.mem j
          in
          if has_edge then go graph edges_added rest last_edge
          else go (add_edge i j graph) (edges_added + 1) rest (i, j)
  in
  go graph 0 all_dists (-1, -1)

let find_cliques graph =
  let rec go cliques inds graph =
    ISet.choose_opt inds
    |> Option.fold ~none:cliques ~some:(fun v ->
        let c = dfs graph v in
        go (IISet.add c cliques) (ISet.diff inds c) graph)
  in
  let inds = List.init (Array.length points) Fun.id |> ISet.of_list in
  go IISet.empty inds graph

let () =
  let graph, _ = connect IMap.empty 1000 in
  let cliques = find_cliques graph in
  IISet.to_list cliques |> List.map ISet.cardinal
  |> List.sort (Fun.flip compare)
  |> List.take 3 |> List.fold_left Int.mul 1 |> print_int;
  print_endline ""

let () =
  let rec go graph last_edge =
    let stop =
      IMap.cardinal graph >= Array.length points - 1
      && IISet.cardinal (find_cliques graph) = 1
    in
    if stop then last_edge
    else
      let graph, last_edge = connect graph 1 in
      go graph last_edge
  in
  let i, j = go IMap.empty (-1, -1) in
  points.(i).x *. points.(j).x |> int_of_float |> print_int
