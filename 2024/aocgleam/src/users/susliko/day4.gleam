import gleam/dict
import gleam/function
import gleam/int
import gleam/io
import gleam/list
import gleam/result
import users/susliko/utils

pub fn main() {
  let assert Ok(chars) = utils.read_chars("inputs/day4/input.txt")
  let map =
    chars
    |> list.index_map(fn(row, i) {
      let row_dict =
        row
        |> list.index_map(fn(c, j) { #(j, c) })
        |> dict.from_list
      #(i, row_dict)
    })
    |> dict.from_list

  part1(map) |> io.debug
  part2(map) |> io.debug
}

fn part1(map) {
  let starts = find_ij(map, fn(el) { el == "X" })
  starts
  |> list.map(fn(start) {
    let #(xi, xj) = start
    let letters = ["X", "M", "A", "S"]
    move(map, xi, xj, letters, fn(i, j) { #(i - 1, j - 1) }).0
    + move(map, xi, xj, letters, fn(i, j) { #(i, j - 1) }).0
    + move(map, xi, xj, letters, fn(i, j) { #(i + 1, j - 1) }).0
    + move(map, xi, xj, letters, fn(i, j) { #(i - 1, j) }).0
    + move(map, xi, xj, letters, fn(i, j) { #(i + 1, j) }).0
    + move(map, xi, xj, letters, fn(i, j) { #(i - 1, j + 1) }).0
    + move(map, xi, xj, letters, fn(i, j) { #(i, j + 1) }).0
    + move(map, xi, xj, letters, fn(i, j) { #(i + 1, j + 1) }).0
  })
  |> list.fold(0, int.add)
}

fn part2(map) {
  let starts = find_ij(map, fn(el) { el == "M" })
  starts
  |> list.flat_map(fn(start) {
    let #(xi, xj) = start
    let letters = ["M", "A", "S"]
    let a = case move(map, xi, xj, letters, fn(i, j) { #(i - 1, j - 1) }) {
      #(1, #(i, j)) -> [#(i + 2, j + 2)]
      _ -> []
    }
    let b = case move(map, xi, xj, letters, fn(i, j) { #(i + 1, j + 1) }) {
      #(1, #(i, j)) -> [#(i - 2, j - 2)]
      _ -> []
    }
    let c = case move(map, xi, xj, letters, fn(i, j) { #(i - 1, j + 1) }) {
      #(1, #(i, j)) -> [#(i + 2, j - 2)]
      _ -> []
    }
    let d = case move(map, xi, xj, letters, fn(i, j) { #(i + 1, j - 1) }) {
      #(1, #(i, j)) -> [#(i - 2, j + 2)]
      _ -> []
    }
    a |> list.append(b) |> list.append(c) |> list.append(d)
  })
  |> list.group(function.identity)
  |> dict.map_values(fn(_, pairs) { list.length(pairs) })
  |> dict.filter(fn(_, counts) { counts == 2 })
  |> dict.size
}

fn find_ij(map, is_ok) {
  map
  |> dict.to_list
  |> list.flat_map(fn(pair) {
    let #(i, row) = pair
    row
    |> dict.to_list
    |> list.filter_map(fn(pair) {
      let #(j, el) = pair
      case is_ok(el) {
        True -> Ok(j)
        False -> Error(Nil)
      }
    })
    |> list.map(fn(j) { #(i, j) })
  })
}

fn move(
  map,
  i: Int,
  j: Int,
  letters: List(String),
  step: fn(Int, Int) -> #(Int, Int),
) -> #(Int, #(Int, Int)) {
  case letters {
    [] -> #(1, #(i, j))
    [letter, ..rest] ->
      {
        use row <- result.try(dict.get(map, i))
        use el <- result.try(dict.get(row, j))
        case el {
          x if x == letter -> {
            let #(i1, j1) = step(i, j)
            Ok(move(map, i1, j1, rest, step))
          }
          _ -> Error(Nil)
        }
      }
      |> result.unwrap(#(0, #(i, j)))
  }
}
