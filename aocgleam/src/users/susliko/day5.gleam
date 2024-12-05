import gleam/dict
import gleam/int
import gleam/io
import gleam/list
import gleam/option.{None, Some}
import gleam/result
import gleam/set
import users/susliko/utils

pub fn main() {
  let assert Ok([raw_rules, raw_updates]) =
    utils.read_line_blocks("inputs/day5/input.txt")

  let rules =
    raw_rules
    |> list.map(utils.parse_line(_, "|", int.parse))
    |> result.values
  let updates =
    raw_updates
    |> list.map(utils.parse_line(_, ",", int.parse))
    |> result.values

  let assert True =
    list.all(updates, fn(update) { list.length(update) % 2 == 1 })

  part1(rules, updates) |> io.debug
  part2(rules, updates) |> io.debug
}

fn part1(rules: List(List(Int)), updates: List(List(Int))) {
  let goes_after = calc_goes_after(rules)

  updates
  |> list.filter_map(fn(update) {
    case check_update(update, goes_after, []) {
      True -> get_mid_el(update)
      False -> Error(Nil)
    }
  })
  |> list.fold(0, int.add)
}

fn part2(rules: List(List(Int)), updates: List(List(Int))) {
  let goes_after = calc_goes_after(rules)

  updates
  |> list.filter_map(fn(update) {
    case check_update(update, goes_after, []) {
      False ->
        update
        |> fix_update(goes_after, [])
        |> get_mid_el
      True -> Error(Nil)
    }
  })
  |> list.fold(0, int.add)
}

fn get_mid_el(xs: List(Int)) {
  let ind = { list.length(xs) - 1 } / 2
  case xs |> list.drop(ind) |> list.first {
    Ok(el) -> Ok(el)
    _ -> Error(Nil)
  }
}

fn calc_goes_after(rules) {
  rules
  |> list.fold(dict.new(), fn(acc, rule) {
    case rule {
      [b, a] ->
        dict.upsert(acc, b, fn(x) {
          case x {
            Some(xs) -> set.insert(xs, a)
            None -> set.new() |> set.insert(a)
          }
        })
      _ -> acc
    }
  })
}

fn check_update(
  update: List(Int),
  goes_after: dict.Dict(Int, set.Set(Int)),
  prev: List(Int),
) {
  case update {
    [] -> True
    [u, ..rest] -> {
      let after = dict.get(goes_after, u) |> result.unwrap(set.new())
      let u_ok = prev |> list.all(fn(el) { !set.contains(after, el) })
      u_ok && check_update(rest, goes_after, list.prepend(prev, u))
    }
  }
}

fn fix_update(
  update: List(Int),
  goes_after: dict.Dict(Int, set.Set(Int)),
  prev: List(Int),
) -> List(Int) {
  case update {
    [] -> prev
    [u, ..rest] -> {
      let after = dict.get(goes_after, u) |> result.unwrap(set.new())
      let #(oks, ers) = prev |> list.partition(set.contains(after, _))
      case ers {
        [] -> fix_update(rest, goes_after, list.prepend(oks, u))
        ers -> fix_update(rest, goes_after, list.flatten([ers, [u], oks]))
      }
    }
  }
}
