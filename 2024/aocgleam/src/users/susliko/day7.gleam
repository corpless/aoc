import gleam/int
import gleam/io
import gleam/list
import users/susliko/utils

pub fn main() {
  let assert Ok(raw_lines) =
    utils.read_input("inputs/day7/input.txt", ":", fn(s) { Ok(s) })
  let lines =
    raw_lines
    |> list.filter_map(fn(line) {
      case line {
        [tot, s] -> {
          case int.parse(tot), utils.parse_line(s, " ", int.parse) {
            Ok(tot), Ok(nums) -> Ok(#(tot, nums))
            _, _ -> Error(Nil)
          }
        }
        _ -> Error(Nil)
      }
    })

  solve(lines, [int.add, int.multiply]) |> io.debug
  solve(lines, [int.add, int.multiply, concat]) |> io.debug
}

fn solve(lines, ops) {
  lines
  |> list.filter(fn(line) {
    let #(tot, nums) = line
    case nums {
      [num, ..nums] -> matches(tot, num, nums, ops)
      _ -> False
    }
  })
  |> io.debug
  |> list.fold(0, fn(acc, p) { acc + p.0 })
}

fn matches(tot, n1, nums, ops) {
  case nums {
    [n2, ..rest] -> {
      list.any(ops, fn(op) { matches(tot, op(n1, n2), rest, ops) })
    }
    [] if n1 == tot -> True
    _ -> False
  }
}

fn concat(a: Int, b: Int) -> Int {
  case int.parse(int.to_string(a) <> int.to_string(b)) {
    Ok(a) -> a
    _ -> 0
  }
}
