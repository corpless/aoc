let ( >> ) f g x = g (f x)

let coords =
  In_channel.with_open_text "inputs/day9/full.txt" In_channel.input_all
  |> String.split_on_char '\n'
  |> List.map
       ( String.split_on_char ',' >> List.map int_of_string >> function
         | [ a; b ] -> (a, b)
         | _ -> failwith "invalid input" )

let all_pairs l =
  let rec iter acc = function
    | [] -> acc
    | x :: xs ->
        let acc = List.fold_left (fun acc y -> (x, y) :: acc) acc xs in
        iter acc xs
  in
  iter [] l

let area = function
  | (a1, b1), (a2, b2) -> (abs (a1 - a2) + 1) * (abs (b1 - b2) + 1)

let _part1 =
  coords |> all_pairs |> List.map area |> List.fold_left max 0 |> string_of_int
  |> print_endline

let edges =
  let coords_rev = coords |> List.rev in
  let coords_last = List.hd coords_rev in
  let coords_shift1 = coords_last :: (coords_rev |> List.drop 1 |> List.rev) in
  List.combine coords coords_shift1

let vert_edges =
  edges
  |> List.filter (function (x1, _y1), (x2, _y2) -> x1 = x2)
  |> List.sort (fun a b -> compare (fst (fst a)) (fst (fst b)))

let hor_edges =
  edges
  |> List.filter (function (_x1, y1), (_x2, y2) -> y1 = y2)
  |> List.sort (fun a b -> compare (snd (fst a)) (snd (fst b)))

let point_in_shape = function
  | px, py ->
      let filtered_edges =
        List.drop_while (function (x1, _y1), (_, _y2) -> x1 < px) vert_edges
      in
      let is_inside_vert_edge =
        match List.nth_opt filtered_edges 0 with
        | None -> false
        | Some ((x1, y1), (_, y2)) ->
            x1 = px && min y1 y2 <= py && max y1 y2 >= py
      in
      let is_inside_hor_edge =
        List.exists
          (function
            | (x1, y1), (x2, _) ->
                y1 == py && min x1 x2 <= px && max x1 x2 >= px)
          hor_edges
      in
      if is_inside_vert_edge || is_inside_hor_edge then true
      else
        (filtered_edges
        |> List.filter (function (_x1, y1), (_, y2) ->
            min y1 y2 <= py && max y1 y2 >= py)
        |> List.length)
        mod 2
        != 0

let lines_intersect ver hor =
  match (ver, hor) with
  | ((vx, vy1), (_vx2, vy2)), ((hx1, hy), (hx2, _hy2)) ->
      if
        vx >= min hx1 hx2
        && vx <= max hx1 hx2
        && hy >= min vy1 vy2
        && hy <= max vy1 vy2
      then Some (vx, hy)
      else None

let get_points_to_check = function
  | (x1, y1), (x2, y2) ->
      let vert_rect_edges = [ ((x1, y1), (x1, y2)); ((x2, y2), (x2, y1)) ] in
      let vert_points_to_check =
        List.concat_map
          (fun ver ->
            List.filter_map (fun hor -> lines_intersect ver hor) hor_edges)
          vert_rect_edges
      in
      let hor_rect_edges = [ ((x1, y2), (x2, y2)); ((x2, y1), (x1, y1)) ] in
      let hor_points_to_check =
        List.concat_map
          (fun hor ->
            List.filter_map (fun ver -> lines_intersect ver hor) vert_edges)
          hor_rect_edges
      in
      List.concat
        [
          vert_points_to_check
          |> List.concat_map (function x, y ->
              [
                (x, min (y + 1) (max y1 y2));
                (x, y);
                (x, max (y - 1) (min y1 y2));
              ]);
          hor_points_to_check
          |> List.concat_map (function x, y ->
              [
                (min (x + 1) (max x1 x2), y);
                (x, y);
                (max (x - 1) (min x1 x2), y);
              ]);
          [ (x1, y1); (x2, y1); (x1, y2); (x2, y2) ];
        ]

let rect_in_shape rect = get_points_to_check rect |> List.for_all point_in_shape

(*let _test = rect_in_shape ((9,5), (2,3))*)

let _part2 =
  coords |> all_pairs |> List.filter rect_in_shape |> List.map area
  |> List.fold_left max 0 |> string_of_int |> print_endline
