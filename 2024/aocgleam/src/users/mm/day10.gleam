import gleam/dict
import gleam/int
import gleam/io
import gleam/list
import gleam/option.{None, Some}
import gleam/result
import gleam/set.{type Set}
import gleam/string
import simplifile

pub type Pos {
  Pos(x: Int, y: Int)
}

fn combine_part1(states: List(Set(Pos))) {
  states
  |> list.fold(set.from_list([]), set.union)
}

fn combine_part2(states: List(Int)) {
  states
  |> list.fold(0, int.add)
}

pub fn traverse(
  depth,
  map,
  prev: List(#(Pos, a)),
  combine_states: fn(List(a)) -> a,
) {
  case depth {
    0 -> prev
    _ -> {
      let next_level =
        dict.get(map, depth - 1)
        |> result.lazy_unwrap(fn() { [] })
        |> set.from_list
      let next =
        prev
        |> list.flat_map(fn(s) {
          let x = { s.0 }.x
          let y = { s.0 }.y
          [
            #(Pos(x + 1, y), s.1),
            #(Pos(x - 1, y), s.1),
            #(Pos(x, y + 1), s.1),
            #(Pos(x, y - 1), s.1),
          ]
        })
        |> list.filter(fn(s) { set.contains(next_level, s.0) })
        |> list.group(fn(s) { s.0 })
        |> dict.map_values(fn(_pos, states) {
          states
          |> list.map(fn(x) { x.1 })
          |> combine_states
        })
        |> dict.to_list
      traverse(depth - 1, map, next, combine_states)
    }
  }
}

pub fn main() {
  let assert Ok(text) = simplifile.read("inputs/day10/input.txt")
  let grid =
    text
    |> string.split("\n")
    |> list.filter(fn(l) { l != "" })
    |> list.map(fn(l) {
      l
      |> string.split("")
      |> list.map(fn(c) {
        let assert Ok(i) = int.parse(c)
        i
      })
    })

  let map =
    grid
    |> list.index_map(fn(line, i) {
      line
      |> list.index_map(fn(h, j) { #(h, Pos(i, j)) })
    })
    |> list.flatten
    |> list.fold(dict.from_list([]), fn(d, cell) {
      let #(h, pos) = cell
      dict.upsert(d, h, fn(old_pos) {
        case old_pos {
          Some(pos_arr) -> [pos, ..pos_arr]
          None -> [pos]
        }
      })
    })
  let init_positions =
    dict.get(map, 9)
    |> result.lazy_unwrap(fn() { [] })

  let init_part1 =
    list.map(init_positions, fn(pos) { #(pos, set.from_list([pos])) })

  traverse(9, map, init_part1, combine_part1)
  |> list.map(fn(state) { set.size(state.1) })
  |> list.fold(0, int.add)
  |> io.debug

  let init_part2 = list.map(init_positions, fn(pos) { #(pos, 1) })

  traverse(9, map, init_part2, combine_part2)
  |> list.map(fn(state) { state.1 })
  |> list.fold(0, int.add)
  |> io.debug
}
