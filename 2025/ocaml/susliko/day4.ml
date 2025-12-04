let prepare lines =
  lines |> Array.of_list |> Array.map (fun l -> Array.of_seq @@ String.to_seq l)

let count data =
  let h = Array.length data in
  let w = Array.length data.(0) in
  let counts = Array.make_matrix h w 0 in
  let inc =
   fun i j ->
    if i >= 0 && i < h && j >= 0 && j < w then
      counts.(i).(j) <- counts.(i).(j) + 1
  in
  for i = 0 to h - 1 do
    for j = 0 to w - 1 do
      if data.(i).(j) == '@' then (
        inc (i - 1) (j - 1);
        inc (i - 1) j;
        inc (i - 1) (j + 1);
        inc i (j - 1);
        inc i (j + 1);
        inc (i + 1) (j - 1);
        inc (i + 1) j;
        inc (i + 1) (j + 1))
    done
  done;
  counts

let modify data =
  let datacopy = Array.map Array.copy data in
  let counts = count data in
  let changes =
    counts
    |> Array.mapi (fun i line ->
        let count = ref 0 in
        line
        |> Array.iteri (fun j c ->
            if data.(i).(j) == '@' && c < 4 then (
              count := !count + 1;
              datacopy.(i).(j) <- '.'));
        !count)
    |> Array.fold_left ( + ) 0
  in
  (datacopy, changes)

let part1 data =
  let _, res = modify data in
  res

let part2 data =
  let c = ref true in
  let arr = ref data in
  let changes = ref 0 in
  while !c do
    let arrcopy, res = modify !arr in
    arr := arrcopy;
    changes := !changes + res;
    if res == 0 then c := false
  done;
  !changes

let () =
  let data = Utils.read_sample 4 |> prepare in
  part1 data |> print_int;
  print_newline ();
  part2 data |> print_int
