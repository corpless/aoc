let range a b =
  let rec range_iter res i rem =
    if rem <= 0 then res else range_iter (i :: res) (i + 1) (rem - 1)
  in
  range_iter [] a (b - a + 1)

let sum l = List.fold_left ( + ) 0 l

let _get_doubles a b =
  let left_half s = String.sub s 0 (String.length s / 2) in
  let right_half s = String.sub s (String.length s / 2) (String.length s / 2) in
  let is_valid i =
    let s = string_of_int i in
    String.length s mod 2 == 0 && left_half s = right_half s
  in
  range a b |> List.filter is_valid |> sum

let get_multiples a b =
    let primes = [2; 3; 5; 7; 11; 13] in (* похуй🚬... *)
    let split_n s n =
      let rec split_iter s part_len res = 
        let len = String.length s in
        if len = 0 then res 
        else 
          let new_part = String.sub s 0 part_len in
          let remainder = String.sub s part_len (len - part_len) in
          split_iter remainder part_len (new_part::res) in
      split_iter s ((String.length s) / n) []
    in
    let all_equal s_arr = match s_arr with
      | [] -> true
      | x::xs -> List.for_all (fun a -> a = x) xs in
    let is_valid_n s n = 
      let len = String.length s in
      ((len mod n) = 0) && (all_equal (split_n s n)) in
    let is_valid s = List.exists (is_valid_n s) primes in
    range a b |> List.map string_of_int |> List.filter is_valid |> List.map int_of_string |> sum

let () =
  In_channel.with_open_text "inputs/day2/full.txt" In_channel.input_all
  |> String.split_on_char ','
  |> List.map (String.split_on_char '-')
  |> List.map (fun p ->
      match p with
      | [ a; b ] -> get_multiples (int_of_string a) (int_of_string b)
      | _ -> failwith "invalid string!")
  |> sum |> string_of_int |> print_endline
