let read_lines file =
  In_channel.with_open_text file In_channel.input_all
  |> String.split_on_char '\n'
  |> List.filter (fun s -> String.length s > 0)

let read_sample day =
  let path = Printf.sprintf "inputs/day%d/sample.txt" day in
  read_lines path

let read_input day =
  let path = Printf.sprintf "inputs/day%d/input.txt" day in
  read_lines path
