import gleam/dict.{type Dict}
import gleam/io
import gleam/list
import gleam/option
import gleam/result
import gleam/set.{type Set}
import users/susliko/utils

pub fn main() {
  let assert Ok(chars) = utils.read_chars("inputs/day6/input.txt")
  let map =
    chars
    |> list.index_map(fn(row, i) {
      let ind_row =
        row
        |> list.index_map(fn(el, j) { #(j, el) })
        |> dict.from_list
      #(i, ind_row)
    })
    |> dict.from_list
  let assert [pos] = find_char(chars, "^") |> io.debug

  part1(map, pos) |> list.length |> io.debug
  part2(map, pos) |> io.debug
}

fn part2(map, pos: #(Int, Int)) {
  part1(map, pos)
  |> list.filter(fn(dot) {
    let #(dot_i, dot_j) = dot
    let #(is_loop, _) =
      patch_map(map, dot_i, dot_j, "#")
      |> walk(pos.0, pos.1, Up, set.new())
    is_loop
  })
  |> list.length
}

fn patch_map(map, i, j, symb) {
  map
  |> dict.upsert(i, fn(opt_row) {
    opt_row
    |> option.map(fn(row) { dict.insert(row, j, symb) })
    |> option.unwrap(dict.new())
  })
}

fn part1(map, pos: #(Int, Int)) {
  let #(_, positions) = walk(map, pos.0, pos.1, Up, set.new())
  positions
  |> set.to_list
  |> list.map(fn(pos) { #(pos.0, pos.1) })
  |> list.unique
}

// First output is whether we found a cycle
fn walk(
  map: Dict(Int, Dict(Int, String)),
  i,
  j,
  direction,
  acc: Set(#(Int, Int, Direction)),
) -> #(Bool, Set(#(Int, Int, Direction))) {
  let pos = #(i, j, direction)
  case set.contains(acc, pos) {
    True -> #(True, acc)
    False -> {
      let #(i2, j2) = case direction {
        Up -> #(i - 1, j)
        Down -> #(i + 1, j)
        Left -> #(i, j - 1)
        Right -> #(i, j + 1)
      }

      case map |> dict.get(i2) |> result.unwrap(dict.new()) |> dict.get(j2) {
        Ok(el) if el == "#" -> walk(map, i, j, turn_right(direction), acc)
        Ok(_) -> walk(map, i2, j2, direction, set.insert(acc, pos))
        Error(_) -> #(False, set.insert(acc, pos))
      }
    }
  }
}

fn find_char(chars, wanted) -> List(#(Int, Int)) {
  chars
  |> list.index_fold([], fn(acc, row, i) {
    let row_acc =
      row
      |> list.index_fold([], fn(acc, el, j) {
        case el {
          x if x == wanted -> list.prepend(acc, #(i, j))
          _ -> acc
        }
      })
    [row_acc, acc] |> list.flatten |> list.reverse
  })
}

type Direction {
  Up
  Down
  Left
  Right
}

fn turn_right(direction: Direction) {
  case direction {
    Up -> Right
    Right -> Down
    Down -> Left
    Left -> Up
  }
}
