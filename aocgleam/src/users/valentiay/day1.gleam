import gleam/int
import gleam/io
import gleam/list
import gleam/result
import users/valentiay/utils

fn similarity_score_loop(left, right, left_count, right_count, res) {
  case left, right {
    [l1, l2, ..ls], _ if l1 == l2 ->
      similarity_score_loop([l2, ..ls], right, left_count + 1, right_count, res)
    _, [r1, r2, ..rs] if r1 == r2 ->
      similarity_score_loop(left, [r2, ..rs], left_count, right_count + 1, res)
    [l1, ..ls], [r1, ..] if l1 < r1 ->
      similarity_score_loop(ls, right, 0, right_count, res)
    [l1, ..], [r1, ..rs] if l1 > r1 ->
      similarity_score_loop(left, rs, left_count, 0, res)
    [l1, ..ls], [r1, ..rs] if l1 == r1 -> {
      let new_res = res + l1 * { left_count + 1 } * { right_count + 1 }
      similarity_score_loop(ls, rs, 0, 0, new_res)
    }
    _, _ -> res
  }
}

pub fn main() {
  use ints <- result.try(utils.read_ints("inputs/day1/input.txt"))
  let #(left, right) =
    ints
    |> list.flat_map(fn(l) {
      case l {
        [x, y] -> [#(x, y)]
        _ -> []
      }
    })
    |> list.unzip

  let left_sorted = list.sort(left, int.compare)
  let right_sorted = list.sort(right, int.compare)

  let distance =
    list.zip(left_sorted, right_sorted)
    |> list.map(fn(pair) {
      let #(x, y) = pair
      int.absolute_value(x - y)
    })
    |> list.fold(0, fn(x, y) { x + y })
  io.debug(distance)

  let similarity = similarity_score_loop(left_sorted, right_sorted, 0, 0, 0)
  io.debug(similarity)

  Ok(0)
}
