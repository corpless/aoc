import gleam/dict
import gleam/function
import gleam/int
import gleam/io
import gleam/list
import gleam/result
import users/susliko/utils

pub fn main() {
  let assert Ok(data) = utils.read_ints("inputs/day1/input.txt")
  let assert [left, right] = list.transpose(data)

  part1(left, right) |> io.debug
  part2(left, right) |> io.debug
}

fn part1(left, right) {
  list.zip(list.sort(left, by: int.compare), list.sort(right, by: int.compare))
  |> list.map(fn(pair) {
    let #(l, r) = pair
    int.absolute_value(l - r)
  })
  |> list.fold(0, fn(acc, el) { acc + el })
}

fn part2(left, right) {
  let counts =
    right
    |> list.group(function.identity)
    |> dict.map_values(fn(_k, vs) { list.length(vs) })
  left
  |> list.fold(0, fn(acc, el) {
    let mult =
      el
      |> dict.get(counts, _)
      |> result.unwrap(0)
    acc + el * mult
  })
}
