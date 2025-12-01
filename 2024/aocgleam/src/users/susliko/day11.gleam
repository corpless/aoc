import gleam/dict
import gleam/int
import gleam/io
import gleam/list
import gleam/option
import gleam/result
import gleam/string
import users/susliko/utils

pub fn main() {
  let assert Ok([stones, ..]) = utils.read_ints("inputs/day11/input.txt")

  solve(agg(stones), 25) |> dict.values |> int.sum |> io.debug
  solve(agg(stones), 75) |> dict.values |> int.sum |> io.debug
}

fn solve(stones, blinks) {
  list.repeat(0, blinks)
  |> list.fold(stones, fn(acc, _) {
    dict.fold(acc, dict.new(), fn(acc, k, v) {
      [rule1, rule2]
      |> list.find_map(fn(rule) { rule(k) })
      |> result.unwrap(rule3(k))
      |> list.fold(acc, fn(acc, el) {
        dict.upsert(acc, el, fn(got_opt) { option.unwrap(got_opt, 0) + v })
      })
    })
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
  let parse = fn(l) { string.join(l, "") |> int.parse }
  case l % 2 {
    0 -> {
      use stonel <- result.try(list.take(digits, l / 2) |> parse)
      use stoner <- result.try(list.drop(digits, l / 2) |> parse)
      Ok([stonel, stoner])
    }
    _ -> Error(Nil)
  }
}

fn rule3(s) {
  [s * 2024]
}

fn agg(l) {
  l |> list.group(fn(a) { a }) |> dict.map_values(fn(_, b) { list.length(b) })
}
