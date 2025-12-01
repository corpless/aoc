import gleam/dict.{type Dict}
import gleam/io
import gleam/list
import gleam/option.{None, Some}
import gleam/result
import gleam/set
import users/susliko/utils

pub fn main() {
  let assert Ok(chars) = utils.read_chars("inputs/day8/input.txt")

  let i_max = list.length(chars)
  let j_max = chars |> list.first |> result.unwrap([]) |> list.length

  let antennas =
    chars
    |> list.index_map(fn(row, i) {
      list.index_map(row, fn(el, j) { #(i, j, el) })
    })
    |> list.flatten
    |> list.fold(dict.new(), fn(acc, el) {
      let #(i, j, sym) = el
      case sym {
        "." | "#" -> acc
        x ->
          dict.upsert(acc, x, fn(opt) {
            case opt {
              None -> [#(i, j)]
              Some(l) -> list.prepend(l, #(i, j))
            }
          })
      }
    })

  part1(antennas, i_max, j_max) |> io.debug
  part2(antennas, i_max, j_max) |> io.debug
}

fn part1(antennas: Dict(String, List(#(Int, Int))), i_max, j_max) {
  antennas
  |> dict.values
  |> list.flat_map(fn(antennas) {
    let s = set.from_list(antennas)
    to_antinodes(antennas, i_max, j_max, 1)
    |> list.filter(fn(p) { !set.contains(s, p) })
  })
  |> list.unique
  |> list.length
}

fn part2(antennas: Dict(String, List(#(Int, Int))), i_max, j_max) {
  antennas
  |> dict.values
  |> list.flat_map(fn(antennas) { to_antinodes(antennas, i_max, j_max, 1000) })
  |> list.unique
  |> list.length
}

fn to_antinodes(ant_pos: List(#(Int, Int)), i_max, j_max, limit) {
  ant_pos
  |> list.combination_pairs
  |> list.flat_map(fn(p) {
    let #(#(i1, j1), #(i2, j2)) = p
    let step1 = fn(i, j) { #(i + { i1 - i2 }, j + { j1 - j2 }) }
    let step2 = fn(i, j) { #(i + { i2 - i1 }, j + { j2 - j1 }) }
    let one =
      replicate(i1, j1, step1, i_max, j_max, [])
      |> list.reverse
      |> list.take(limit)
    let another =
      replicate(i2, j2, step2, i_max, j_max, [])
      |> list.reverse
      |> list.take(limit)
    list.flatten([one, another, [#(i1, j1), #(i2, j2)]])
  })
}

fn replicate(i, j, step, i_max, j_max, acc) {
  case step(i, j) {
    #(i, j) if i >= 0 && j >= 0 && i < i_max && j < j_max ->
      replicate(i, j, step, i_max, j_max, list.prepend(acc, #(i, j)))
    _ -> acc
  }
}
