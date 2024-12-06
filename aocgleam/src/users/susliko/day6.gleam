import gleam/dict
import gleam/io
import gleam/list
import users/susliko/utils

pub fn main() {
  let assert Ok(chars) = utils.read_chars("inputs/day6/sample.txt")
  let obst = find_char(chars, "#") |> io.debug
  let assert [pos] = find_char(chars, "^") |> io.debug
  part1(obst, pos)
}

fn part1(obst: List(#(Int, Int)), pos) {
  let left =
    obst
    |> list.group(fn(o) { o.0 })
    |> dict.map_values(fn(_, l) { list.map(l, fn(p) { p.1 }) })
  let right = left |> dict.map_values(fn(_, l) { list.reverse(l) })
  let top =
    obst
    |> list.group(fn(o) { o.1 })
    |> dict.map_values(fn(_, l) { list.map(l, fn(p) { p.0 }) })
  let bottom = left |> dict.map_values(fn(_, l) { list.reverse(l) })
}

/// left, right, top, bottom are dicts of obstacles by required direction
fn walk(left, right, top, bottom, pos) {

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
