import gleam/io
import gleam/list
import users/susliko/utils

pub fn main() {
  let assert Ok(data) = utils.read_ints("inputs/day2/input.txt")
  part1(data) |> io.debug
  part2(data) |> io.debug
}

fn part1(data: List(List(Int))) {
  list.count(data, fn(row) {
    row
    |> list.window_by_2
    |> are_monotonic_pairs
  })
}

fn part2(data: List(List(Int))) {
  list.count(data, fn(row) {
    list.range(0, list.length(row) - 1)
    |> list.map(fn(ind) {
      let a = list.take(row, ind)
      let b = list.drop(row, ind + 1)
      list.append(a, b) |> list.window_by_2
    })
    |> list.any(are_monotonic_pairs)
  })
}

fn are_monotonic_pairs(pairs: List(#(Int, Int))) {
  let is_monotonic_pair = fn(a, b) { a - b >= 1 && a - b <= 3 }
  list.all(pairs, fn(p) { is_monotonic_pair(p.0, p.1) })
  || list.all(pairs, fn(p) { is_monotonic_pair(p.1, p.0) })
}
