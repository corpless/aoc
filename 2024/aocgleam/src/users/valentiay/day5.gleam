import gleam/dict
import gleam/int
import gleam/io
import gleam/list
import gleam/order
import gleam/result
import gleam/set
import gleam/string
import users/valentiay/utils

fn is_correct_update(
  order: dict.Dict(String, set.Set(String)),
  update: List(String),
) -> Bool {
  case update {
    [] -> True
    [page, ..other] -> {
      case order |> dict.get(page) {
        Ok(forbidden) ->
          case other |> list.any(set.contains(forbidden, _)) {
            True -> False
            False -> is_correct_update(order, other)
          }
        _ -> is_correct_update(order, other)
      }
    }
  }
}

fn sum_middle_pages(updates: List(List(String))) -> Int {
  updates
  |> list.map(fn(update) {
    update
    |> list.drop(list.length(update) / 2)
    |> list.first
    |> result.map(int.parse)
    |> result.flatten
    |> result.unwrap(0)
  })
  |> list.fold(0, fn(acc, i) { acc + i })
}

pub fn main() {
  use str <- result.try(utils.read_string("inputs/day5/input.txt"))
  let lines = str |> string.split("\n")
  let order =
    lines
    |> list.take_while(fn(line) { line |> string.contains("|") })
    |> list.flat_map(fn(line) {
      case line |> string.split("|") {
        [x, y] -> [#(y, x)]
        _ -> []
      }
    })
    |> list.group(fn(x) { x.0 })
    |> dict.map_values(fn(_, pairs) {
      pairs |> list.map(fn(p) { p.1 }) |> set.from_list
    })

  let updates =
    lines
    |> list.drop_while(fn(line) { !string.contains(line, ",") })
    |> list.filter(fn(line) { !string.is_empty(line) })
    |> list.map(fn(line) { line |> string.split(",") })

  updates
  |> list.filter(is_correct_update(order, _))
  |> sum_middle_pages
  |> io.debug

  updates
  |> list.filter(fn(update) { !is_correct_update(order, update) })
  |> list.map(fn(update) {
    let compare = fn(x, y) {
      case
        order
        |> dict.get(y)
        |> result.map(fn(less) { less |> set.contains(x) })
      {
        Ok(False) -> order.Lt
        Ok(True) -> order.Gt
        _ -> string.compare(x, y)
      }
    }
    update |> list.sort(compare)
  })
  |> sum_middle_pages
  |> io.debug

  Ok(0)
}
