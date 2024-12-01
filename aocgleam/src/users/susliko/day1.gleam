import gleam/int
import gleam/io
import gleam/list
import users/susliko/utils

pub fn main() {
  let assert Ok(data) = utils.read_ints("inputs/day1/input.txt")
  let assert [left, right] = list.transpose(data)

  list.zip(list.sort(left, by: int.compare), list.sort(right, by: int.compare))
  |> list.map(fn(pair) {
    let #(l, r) = pair
    int.absolute_value(l - r)
  })
  |> list.fold(0, fn(acc, el) { acc + el })
  |> io.debug
}
