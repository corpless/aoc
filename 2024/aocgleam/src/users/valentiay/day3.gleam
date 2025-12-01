import gleam/int
import gleam/io
import gleam/list
import gleam/option
import gleam/regexp
import gleam/result
import users/valentiay/utils

fn mul(submatches: List(option.Option(String))) -> Int {
  submatches
  |> list.map(fn(num) {
    num
    |> option.map(int.parse(_))
    |> option.map(option.from_result(_))
    |> option.flatten
    |> option.unwrap(0)
  })
  |> list.fold(1, fn(res, item) { res * item })
}

pub fn main() {
  use mul_rex <- result.try(
    regexp.from_string("mul\\((\\d+),(\\d+)\\)")
    |> result.map_error(fn(_) { Nil }),
  )
  use dos_rex <- result.try(
    regexp.from_string("mul\\((\\d+),(\\d+)\\)|do\\(\\)|don't\\(\\)")
    |> result.map_error(fn(_) { Nil }),
  )
  use string <- result.try(
    utils.read_string("inputs/day3/input.txt")
    |> result.map_error(fn(_) { Nil }),
  )

  regexp.scan(mul_rex, string)
  |> list.map(fn(match) { mul(match.submatches) })
  |> list.fold(0, fn(res, item) { res + item })
  |> io.debug

  regexp.scan(dos_rex, string)
  |> list.fold(#(True, 0), fn(state, match) {
    let #(enabled, res) = state
    case match.content {
      "do()" -> #(True, res)
      "don't()" -> #(False, res)
      _ if enabled -> #(True, res + mul(match.submatches))
      _ -> state
    }
  })
  |> io.debug

  Ok(0)
}
