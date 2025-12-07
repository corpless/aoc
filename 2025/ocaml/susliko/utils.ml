let read_lines file =
  In_channel.with_open_text file In_channel.input_all
  |> String.split_on_char '\n'

let read_sample day =
  let path = Printf.sprintf "inputs/day%d/sample.txt" day in
  read_lines path

let read_input day =
  let path = Printf.sprintf "inputs/day%d/input.txt" day in
  read_lines path

let print_tuple (a, b) = Printf.printf "(%d, %d) " a b

let print_int_tuple_list lst =
  Printf.printf "[";
  List.iter print_tuple lst;
  Printf.printf "]\n"

let print_int_list lst =
  Printf.printf "[";
  List.iter (Printf.printf "%d ") lst;
  Printf.printf "]\n"

let print_str_list lst =
  Printf.printf "[";
  List.iter (Printf.printf "%s ") lst;
  Printf.printf "]\n"

let tap f x =
  f x;
  x

let group_by ~key lst =
  let tbl = Hashtbl.create 16 in
  List.iter
    (fun x ->
      let k = key x in
      let existing = try Hashtbl.find tbl k with Not_found -> [] in
      Hashtbl.replace tbl k (x :: existing))
    lst;
  Hashtbl.fold (fun k v acc -> (k, List.rev v) :: acc) tbl []
