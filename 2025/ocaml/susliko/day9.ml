let points =
  Utils.read_input 9
  |> List.filter (( <> ) "")
  |> List.map (fun line ->
      match String.split_on_char ',' line |> List.map int_of_string with
      | [ x; y ] -> (x, y)
      | _ -> failwith @@ Printf.sprintf "Oh no: %s" line)

let compress_coords coords =
  coords |> List.sort_uniq compare
  |> List.concat_map (fun c -> [ -1; c ])
  |> List.mapi (fun i c -> (c, i))
  |> List.filter (fun (c, _) -> c <> -1)
  |> List.to_seq |> Hashtbl.of_seq

let x_map = points |> List.map fst |> compress_coords
let y_map = points |> List.map snd |> compress_coords
let find_compressed coord map = Hashtbl.find map coord
let max_coord map = Hashtbl.to_seq_values map |> Seq.fold_left max 0 |> ( + ) 2
let max_x = max_coord x_map
let max_y = max_coord y_map
let grid = Array.make_matrix max_x max_y ' '

let crushed_points =
  points
  |> List.map (fun (x, y) -> (find_compressed x x_map, find_compressed y y_map))

let draw_line (x1, y1) (x2, y2) =
  let minx, maxx = (min x1 x2, max x1 x2) in
  let miny, maxy = (min y1 y2, max y1 y2) in
  for x = minx to maxx do
    for y = miny to maxy do
      grid.(x).(y) <- '#'
    done
  done

let () =
  crushed_points @ [ List.hd crushed_points ]
  |> List.fold_left
       (fun prev curr ->
         draw_line prev curr;
         curr)
       (List.hd crushed_points)
  |> ignore

let flood_fill () =
  let queue = Queue.create () in
  let visited = Hashtbl.create (max_x * max_y) in
  Queue.add (0, 0) queue;

  while not (Queue.is_empty queue) do
    let x, y = Queue.take queue in
    if
      x >= 0 && x < max_x && y >= 0 && y < max_y
      && grid.(x).(y) = ' '
      && not (Hashtbl.mem visited (x, y))
    then begin
      grid.(x).(y) <- '.';
      Hashtbl.add visited (x, y) true;
      Queue.add (x - 1, y) queue;
      Queue.add (x + 1, y) queue;
      Queue.add (x, y - 1) queue;
      Queue.add (x, y + 1) queue
    end
  done

let () = flood_fill ()

let rect_valid (x1, y1) (x2, y2) =
  let minx, maxx = (min x1 x2, max x1 x2) in
  let miny, maxy = (min y1 y2, max y1 y2) in
  let exception Invalid in
  try
    for x = minx to maxx do
      for y = miny to maxy do
        if x >= max_x || y >= max_y || grid.(x).(y) = '.' then raise Invalid
      done
    done;
    true
  with Invalid -> false

let area (x1, y1) (x2, y2) = (abs (x1 - x2) + 1) * (abs (y1 - y2) + 1)

let () =
  let all_pairs =
    List.concat_map (fun p1 -> List.map (fun p2 -> (p1, p2)) points) points
  in

  let crush_and_check (p1, p2) =
    let cp1 =
      (find_compressed (fst p1) x_map, find_compressed (snd p1) y_map)
    in
    let cp2 =
      (find_compressed (fst p2) x_map, find_compressed (snd p2) y_map)
    in
    if rect_valid cp1 cp2 then Some (area p1 p2) else None
  in

  let result =
    all_pairs
    |> List.sort (fun (p1, p2) (p3, p4) -> compare (area p3 p4) (area p1 p2))
    |> List.find_map crush_and_check
  in

  match result with
  | Some area -> Printf.printf "%d\n" area
  | None -> failwith "No valid rectangle found"
