import gleam/float
import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/string
import users/valentiay/utils

fn count_digits(num: Int, count: Int) -> Int {
  case num < 10 {
    True -> count
    False -> count_digits(num / 10, count + 1)
  }
}

pub fn is_possible(ans: Int, nums: List(Int), can_cat: Bool) -> Bool {
  case nums {
    _ if ans < 0 -> False
    [] -> ans == 0
    [num, ..rest] -> {
      let is_div_possible = fn() {
        let can_div =
          int.modulo(ans, num)
          |> result.map(fn(res) { res == 0 })
          |> result.unwrap(False)
        can_div && is_possible(ans / num, rest, can_cat)
      }
      let is_cat_possible = fn() {
        let drop_digits =
          int.power(10, count_digits(num, 1) |> int.to_float)
          |> result.unwrap(0.0)
          |> float.round
        can_cat
        && ans - num != 0
        && int.modulo(ans, drop_digits) == Ok(num)
        && is_possible({ ans - num } / drop_digits, rest, can_cat)
      }
      let is_sub_possible = fn() { is_possible(ans - num, rest, can_cat) }
      is_div_possible() || is_cat_possible() || is_sub_possible()
    }
  }
}

pub fn main() {
  use str <- result.try(utils.read_string("inputs/day7/input.txt"))
  let exprs =
    str
    |> string.split("\n")
    |> list.map(fn(line) {
      case line |> string.split(":") {
        [ans_str, ops_str] -> {
          let ans = ans_str |> int.parse |> result.unwrap(0)
          let nums =
            ops_str
            |> string.trim
            |> string.split(" ")
            |> list.map(fn(num) { num |> int.parse |> result.unwrap(0) })
            |> list.reverse
          #(ans, nums)
        }
        _ -> #(0, [])
      }
    })

  exprs
  |> list.map(fn(expr) {
    let #(ans, nums) = expr
    case is_possible(ans, nums, False) {
      True -> ans
      False -> 0
    }
  })
  |> list.fold(0, fn(acc, ans) { acc + ans })
  |> io.debug

  exprs
  |> list.map(fn(expr) {
    let #(ans, nums) = expr
    case is_possible(ans, nums, True) {
      True -> ans
      False -> 0
    }
  })
  |> list.fold(0, fn(acc, ans) { acc + ans })
  |> io.debug

  Ok(0)
}
