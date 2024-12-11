import gleam/dict
import gleam/int
import gleam/io
import gleam/list
import gleam/string
import simplifile

fn calc(state, n_steps_left) {
  case n_steps_left {
    0 -> state
    _ ->
      state
      |> dict.to_list
      |> list.flat_map(fn(s) {
        let #(i, n_stones) = s
        case i {
          0 -> [#(1, n_stones)]
          _ -> {
            let s = int.to_string(i)
            let l = string.length(s)
            case l % 2 == 0 {
              True -> {
                let assert Ok(i1) = int.parse(string.slice(s, 0, l / 2))
                let assert Ok(i2) = int.parse(string.slice(s, l / 2, l / 2))
                [#(i1, n_stones), #(i2, n_stones)]
              }
              False -> [#(i * 2024, n_stones)]
            }
          }
        }
      })
      |> list.group(fn(x) { x.0 })
      |> dict.map_values(fn(_key, l) {
        l |> list.map(fn(x) { x.1 }) |> list.fold(0, int.add)
      })
      |> calc(n_steps_left - 1)
  }
}

pub fn main() {
  let assert Ok(text) = simplifile.read("inputs/day11/input.txt")
  let nums =
    text
    |> string.trim
    |> string.split(" ")
    |> list.map(fn(num) {
      let assert Ok(i) = int.parse(num)
      i
    })
    |> list.group(fn(x) { x })
    |> dict.map_values(fn(_key, x) { list.length(x) })

  nums
  |> calc(25)
  |> dict.to_list
  |> list.map(fn(x) { x.1 })
  |> list.fold(0, int.add)
  |> io.debug

  nums
  |> calc(75)
  |> dict.to_list
  |> list.map(fn(x) { x.1 })
  |> list.fold(0, int.add)
  |> io.debug
}
