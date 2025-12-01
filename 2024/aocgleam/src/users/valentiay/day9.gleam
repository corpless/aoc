import gleam/int
import gleam/io
import gleam/result
import gleam/string
import users/valentiay/utils

fn check_sum(
  str: String,
  idx: Int,
  pos: Int,
  fwd_count: Int,
  rev_idx: Int,
  rev_count: Int,
  sum: Int,
) -> Int {
  let char =
    str
    |> string.drop_start(idx)
    |> string.first
    |> result.try(int.parse)
    |> result.unwrap(0)
  let rev_char =
    str
    |> string.drop_start(rev_idx)
    |> string.first
    |> result.try(int.parse)
    |> result.unwrap(0)
  case idx < rev_idx, fwd_count < char, idx % 2 == 0 {
    False, _, _ ->
      case 0 <= rev_count && rev_count < rev_char {
        False -> sum
        True ->
          check_sum(
            str,
            idx,
            pos + 1,
            0,
            rev_idx,
            rev_count + 1,
            sum + rev_idx / 2 * pos,
          )
      }
    _, False, _ -> check_sum(str, idx + 1, pos, 0, rev_idx, rev_count, sum)
    _, _, True ->
      check_sum(
        str,
        idx,
        pos + 1,
        fwd_count + 1,
        rev_idx,
        rev_count,
        sum + idx / 2 * pos,
      )
    _, _, _ ->
      case rev_count < rev_char {
        True ->
          check_sum(
            str,
            idx,
            pos + 1,
            fwd_count + 1,
            rev_idx,
            rev_count + 1,
            sum + rev_idx / 2 * pos,
          )
        False -> check_sum(str, idx, pos, fwd_count, rev_idx - 2, 0, sum)
      }
  }
}

pub fn main() {
  use str <- result.try(utils.read_string("inputs/day9/input.txt"))
  io.debug(str)
  check_sum(
    str |> string.trim,
    0,
    0,
    0,
    { str |> string.trim |> string.length } - 1,
    0,
    0,
  )
  |> io.debug
  Ok(0)
}
