import gleam/int
import gleam/io
import gleam/list
import gleam/order
import gleam/string
import simplifile

fn skip_at_iter(l, pos, i, res) {
  case l {
    [head, ..tail] -> {
      case i == pos {
        True -> skip_at_iter(tail, pos, i + 1, res)
        False -> skip_at_iter(tail, pos, i + 1, [head, ..res])
      }
    }
    [] -> res
  }
}

fn skip_at(l, pos) {
  list.reverse(skip_at_iter(l, pos, 0, []))
}

fn get_diffs(l, res) {
  case l {
    [head, next, ..tail] -> get_diffs([next, ..tail], [head - next, ..res])
    [_] -> res
    [] -> res
  }
}

fn check_diffs(l) {
  let is_monotonous = case l {
    [] -> True
    [head, ..] ->
      case int.compare(head, 0) {
        order.Eq -> False
        order.Gt -> list.all(l, fn(x) { x > 0 })
        order.Lt -> list.all(l, fn(x) { x < 0 })
      }
  }

  let is_in_bounds =
    list.all(l, fn(x) {
      int.absolute_value(x) >= 1 && int.absolute_value(x) <= 3
    })
  is_monotonous && is_in_bounds
}

pub fn main() {
  let assert Ok(text) = simplifile.read("inputs/day2/sample.txt")
  let nums =
    text
    |> string.split("\n")
    |> list.filter(fn(x) { x != "" })
    |> list.map(fn(line) {
      line
      |> string.split(" ")
      |> list.map(int.parse)
      |> list.map(fn(x) {
        case x {
          Ok(num) -> num
          Error(_) -> panic as "invalid int"
        }
      })
    })

  nums
  |> list.count(fn(line) {
    line
    |> get_diffs([])
    |> check_diffs
  })
  |> io.debug

  nums
  |> list.count(fn(line) {
    list.any(list.range(0, list.length(line)), fn(pos) {
      line
      |> skip_at(pos)
      |> get_diffs([])
      |> check_diffs
    })
  })
  |> io.debug
}
