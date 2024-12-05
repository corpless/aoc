import gleam/dict
import gleam/int
import gleam/io
import gleam/list
import gleam/option.{None, Some}
import gleam/result
import gleam/set
import gleam/set
import users/susliko/utils

pub fn main() {
  let assert Ok([raw_rules, raw_updates]) =
    utils.read_line_blocks("inputs/day5/sample.txt")

  let rules =
    raw_rules
    |> list.map(utils.parse_line(_, "|", int.parse))
    |> result.values
  let updates =
    raw_updates
    |> list.map(utils.parse_line(_, ",", int.parse))
    |> result.values
}

fn part1(rules: List(List(Int)), updates: List(List(Int))) {
  let goes_after =
    rules
    |> list.fold(dict.new(), fn(acc, rule) {
      case rule {
        [b, a] ->
          dict.upsert(acc, b, fn(x) {
            case x {
              Some(xs) -> set.insert(xs, a)
              None -> set.new()
            }
          })
        _ -> acc
      }
    })

  updates
  |> list.filter(fn(update) { update |> list.all(check_update(goes_after, [])) })
}

fn check_update(update, goes_after: set.Set(Int), prev: List(Int)) {
  case update {
    [] -> True
    [u, ..rest] ->
      case dict.get(goes_after, u) {
        Error(_) -> check_update(rest, goes_after, list.append(prev, u))
        Ok(after) -> prev |> list.all(fn(el) { !set.contains(after, el) })
      }
  }
}
