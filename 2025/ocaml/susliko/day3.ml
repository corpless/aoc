let prepare s =
  s
  |> List.map (fun line ->
      String.to_seq line
      |> Seq.map (fun c -> Char.code c - Char.code '0')
      |> Array.of_seq)

let max arr l r =
  let mi = ref (-1) in
  let m = ref (-1) in
  for i = l to r do
    if arr.(i) > !m then (
      m := arr.(i);
      mi := i)
  done;
  (!mi, !m)

let solve banks needed =
  let solve_bank =
   fun bank ->
    let acc = ref 0 in
    let l = ref 0 in
    for left = needed - 1 downto 0 do
      let ai, a = max bank !l (Array.length bank - 1 - left) in
      acc := (!acc * 10) + a;
      l := ai + 1
    done;
    !acc
  in
  let res = List.map solve_bank banks in
  List.fold_left ( + ) 0 res

let () =
  let raw = Utils.read_input 3 in
  let input = prepare raw in
  print_int (solve input 2); (* part 1 *)
  print_newline ();
  print_int (solve input 12) (* part 2 *)

