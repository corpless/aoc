import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/string
import users/valentiay/utils

pub fn main() {
  let assert Ok([stones, ..]) = utils.read_ints("inputs/day11/input.txt")

  part1(stones, 25) |> io.debug
}

fn part1(stones, blinks) {
  list.repeat(0, blinks)
  |> list.fold(stones, fn(acc, _) { blink(acc) |> io.debug })
  |> list.length
}

fn blink(stones) {
  stones
  |> list.flat_map(fn(stone) {
    [rule1, rule2]
    |> list.find_map(fn(rule) { rule(stone) })
    |> result.unwrap(rule3(stone))
  })
}

fn rule1(s) {
  case s {
    0 -> Ok([1])
    _ -> Error(Nil)
  }
}

fn rule2(s) {
  let digits = int.to_string(s) |> string.split("")
  let l = list.length(digits)
  case l % 2 {
    0 -> {
      use stonel <- result.try(
        list.take(digits, l / 2) |> string.join("") |> int.parse,
      )
      use stoner <- result.try(
        list.drop(digits, l / 2) |> string.join("") |> int.parse,
      )
      Ok([stonel, stoner])
    }
    _ -> Error(Nil)
  }
}

fn rule3(s) {
  [s * 2024]
}
