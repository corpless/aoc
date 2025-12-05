let prepare lines =
  let ranges =
    lines
    |> List.take_while (( <> ) "")
    |> List.map (fun x ->
        let ints =
          x |> String.split_on_char '-'
          |> List.filter (( <> ) "")
          |> List.map int_of_string
        in
        match ints with [ a; b ] -> (a, b) | _ -> failwith "invalid input")
  in
  let products =
    List.drop (List.length ranges + 1) lines
    |> List.filter (( <> ) "")
    |> List.map int_of_string
  in
  (ranges, products)

let in_range n (low, high) = n >= low && n <= high

let part1 ranges products =
  products
  |> List.filter (fun p -> ranges |> List.exists (in_range p))
  |> List.length |> print_int

let part2 ranges =
  let merge acc (curs, cure) =
    match acc with
    | [] -> [ (curs, cure) ]
    | (lasts, laste) :: tail ->
        if curs <= laste then (lasts, max laste cure) :: tail
        else (curs, cure) :: acc
  in
  let sorted =
    List.sort
      (fun (a, b) (c, d) -> if a = c then compare b d else compare a c)
      ranges
  in
  List.fold_left merge [] sorted
  |> List.map (fun (a, b) -> b - a + 1)
  |> List.fold_left ( + ) 0 |> print_int

let () =
  let ranges, products = Utils.read_input 5 |> prepare in
  part1 ranges products;
  print_newline ();
  part2 ranges
