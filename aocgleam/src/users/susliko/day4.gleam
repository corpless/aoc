import gleam/dict.{type Dict}
import gleam/io
import gleam/list
import gleam/result
import gleam/string
import users/susliko/utils

pub fn main() {
  let assert Ok(chars) = utils.read_chars("inputs/day4/sample.txt")
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
}

fn part1(map) {
  let starts = find_ij(map, fn(el) { el == "X" }) |> io.debug
  search(["M", "A", "S"], map, starts)
  |> list.length
}

fn search(letters: List(String), map, positions: List(#(Int, Int))) {
  case letters {
    [] -> positions
    [letter, ..rest] -> {
      let next_positions =
        positions
        |> list.flat_map(fn(pos) {
          let #(i, j) = pos
          step(map, i, j, letter)
        })
      io.debug(next_positions)
      io.debug(letter)
      io.debug(list.length(next_positions))
      search(rest, map, next_positions)
    }
  }
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

fn step(map, i: Int, j: Int, search_for: String) -> List(#(Int, Int)) {
  let steps = [
    #(i - 1, j - 1),
    #(i - 1, j),
    #(i + 1, j),
    #(i, j - 1),
    #(i, j + 1),
    #(i + 1, j - 1),
    #(i + 1, j),
    #(i + 1, j + 1),
  ]
  steps
  |> list.filter(fn(step) {
    {
      use row <- result.try(dict.get(map, step.0))
      use el <- result.try(dict.get(row, step.1))
      case el {
        x if x == search_for -> Ok(True)
        _ -> Error(Nil)
      }
    }
    |> result.unwrap(False)
  })
}
