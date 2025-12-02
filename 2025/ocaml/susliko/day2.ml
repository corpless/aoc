let parse s =
  String.split_on_char ',' s
  |> List.filter_map (fun sr ->
      let sp = String.split_on_char '-' sr in
      match sp with
      | [ a; b ] -> Some (int_of_string a, int_of_string b)
      | _ -> None)

let solve predicate ranges =
  let range_filter =
   fun a b ->
    let nums = List.init (b - a + 1) (fun i -> a + i) in
    List.filter predicate nums
  in
  List.concat_map (fun (a, b) -> range_filter a b) ranges
  |> List.fold_left ( + ) 0
  |> Utils.tap (fun i -> print_endline (string_of_int i))

let part1gotcha num =
  let s = string_of_int num in
  let len = String.length s in
  if len mod 2 <> 0 then false
  else
    let half = len / 2 in
    String.sub s 0 half = String.sub s half half

let chunk_string n s =
  let len = String.length s in
  Seq.unfold
    (fun i ->
      if i >= len then None
      else
        let chunk = min (len - i) n in
        Some (String.sub s i chunk, i + n))
    0
  |> List.of_seq

let part2gotcha num =
  let s = string_of_int num in
  let slen = String.length s in
  let divs = slen / 2 in
  let attempts = List.init divs (fun i -> i + 1) in

  let found =
    List.filter_map
      (fun i ->
        if slen mod i <> 0 then None
        else
          let chunks = chunk_string i s in
          match chunks with
          | x :: xs when List.for_all (( = ) x) xs -> Some i
          | _ -> None)
      attempts
  in
  found <> []

let () =
  let input = Utils.read_input 2 in
  let parsed = parse (List.hd input) in
  solve part1gotcha parsed |> ignore;
  solve part2gotcha parsed |> ignore
