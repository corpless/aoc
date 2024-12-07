import gleam/dict
import gleam/int
import gleam/io
import gleam/list
import gleam/order
import gleam/set
import gleam/string
import simplifile

fn try_remove_suffix(a, b) {
  let astr = int.to_string(a)
  let bstr = int.to_string(b)
  case string.ends_with(astr, bstr) {
    True -> {
      let assert Ok(rest) =
        int.parse(string.drop_end(astr, string.length(bstr)))
      Ok(rest)
    }
    False -> Error(Nil)
  }
}

fn check(use_concat, expected_result, nums) {
  case nums {
    [] -> False
    [num, ..rest] -> {
      case int.compare(expected_result, num) {
        order.Eq -> True
        order.Lt -> False
        order.Gt -> {
          let res_mul = case expected_result % num {
            0 -> check(use_concat, expected_result / num, rest)
            _ -> False
          }
          let res_concat = case use_concat {
            True ->
              case try_remove_suffix(expected_result, num) {
                Ok(remainder) -> check(use_concat, remainder, rest)
                _ -> False
              }
            False -> False
          }

          let res_add = check(use_concat, expected_result - num, rest)
          res_mul || res_concat || res_add
        }
      }
    }
  }
}

pub fn main() {
  let assert Ok(text) = simplifile.read("inputs/day7/input.txt")
  let commands =
    text
    |> string.split("\n")
    |> list.filter(fn(l) { l != "" })
    |> list.map(fn(l) {
      l
      |> string.replace(":", "")
      |> string.split(" ")
      |> list.map(fn(s) {
        let assert Ok(s) = int.parse(s)
        s
      })
    })
    |> list.map(fn(l) {
      let assert [first, ..rest] = l
      #(first, list.reverse(rest))
    })

  commands
  |> list.filter_map(fn(c) {
    case check(False, c.0, c.1) {
      True -> Ok(c.0)
      False -> Error(Nil)
    }
  })
  |> list.fold(0, int.add)
  |> io.debug

  commands
  |> list.filter_map(fn(c) {
    case check(True, c.0, c.1) {
      True -> Ok(c.0)
      False -> Error(Nil)
    }
  })
  |> list.fold(0, int.add)
  |> io.debug
}
