import gleam/dict
import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/set
import gleam/string
import users/valentiay/utils

type Vec =
  #(Int, Int)

fn get_antinodes(a: Vec, b: Vec, max: Vec) -> List(Vec) {
  let dist_x = b.0 - a.0
  let dist_y = b.1 - a.1
  [#(a.0 - dist_x, a.1 - dist_y), #(a.0 + 2 * dist_x, a.1 + 2 * dist_y)]
  |> list.filter(fn(p) { 0 <= p.0 && p.0 <= max.0 && 0 <= p.1 && p.1 <= max.1 })
}

fn take_resonances_while(
  start: Vec,
  dist: Vec,
  max: Vec,
  d: Int,
  acc: List(Vec),
) -> List(Vec) {
  let new_x = start.0 + d * dist.0
  let new_y = start.1 + d * dist.1
  let new_d = case d < 0 {
    True -> d - 1
    False -> d + 1
  }
  case 0 <= new_x && new_x <= max.0 && 0 <= new_y && new_y <= max.1 {
    True ->
      take_resonances_while(start, dist, max, new_d, [#(new_x, new_y), ..acc])
    False -> acc
  }
}

fn get_resonances(a: Vec, b: Vec, max: Vec) -> List(Vec) {
  let dist = #(b.0 - a.0, b.1 - a.1)
  let neg = take_resonances_while(a, dist, max, -1, [])
  let pos = take_resonances_while(a, dist, max, 0, [])
  list.append(neg, pos)
}

fn get_all_antinodes(
  matrix: dict.Dict(Vec, String),
  max: Vec,
  f,
) -> set.Set(Vec) {
  matrix
  |> dict.keys
  |> list.flat_map(fn(a) {
    matrix
    |> dict.keys
    |> list.flat_map(fn(b) {
      case a == b {
        True -> []
        False -> [#(a, b)]
      }
    })
  })
  |> list.flat_map(fn(p) { f(p.0, p.1, max) })
  |> set.from_list
}

pub fn main() {
  use str <- result.try(utils.read_string("inputs/day8/input.txt"))

  let matrix =
    str
    |> string.split("\n")
    |> list.index_map(fn(line, y) {
      line
      |> string.to_graphemes
      |> list.index_map(fn(ch, x) { #(#(x, y), ch) })
    })
    |> list.flatten

  let groups =
    matrix
    |> list.group(fn(x) { x.1 })
    |> dict.filter(fn(k, _) { k != "." })
    |> dict.values
    |> list.map(fn(group) { dict.from_list(group) })

  let max_x = matrix |> list.fold(0, fn(a, p) { int.max(a, p.0.0) })
  let max_y = matrix |> list.fold(0, fn(a, p) { int.max(a, p.0.1) })
  let max = #(max_x, max_y)

  groups
  |> list.map(fn(group) { get_all_antinodes(group, max, get_antinodes) })
  |> list.fold(set.new(), fn(acc, item) { set.union(acc, item) })
  |> set.size
  |> io.debug

  groups
  |> list.map(fn(group) { get_all_antinodes(group, max, get_resonances) })
  |> list.fold(set.new(), fn(acc, item) { set.union(acc, item) })
  |> set.size
  |> io.debug

  Ok(0)
}
