import gleam/int
import gleam/io
import gleam/list
import gleam/string
import simplifile

fn try_get_number(s) {
  case int.parse(string.slice(s, 0, 3)) {
    Ok(num) -> Ok(#(num, string.drop_start(s, 3)))
    _ -> {
      case int.parse(string.slice(s, 0, 2)) {
        Ok(num) -> Ok(#(num, string.drop_start(s, 2)))
        _ -> {
          case int.parse(string.slice(s, 0, 1)) {
            Ok(num) -> Ok(#(num, string.drop_start(s, 1)))
            _ -> Error("no int found")
          }
        }
      }
    }
  }
}

type State {
  Do
  Dont
}

fn parse_iter(s, state, res) {
  case s {
    "do()" <> rest -> {
      parse_iter(rest, Do, res)
    }
    "don't()" <> rest -> {
      parse_iter(rest, Dont, res)
    }
    "" -> res
    _ ->
      case s {
        "mul(" <> rest -> {
          case try_get_number(rest) {
            Ok(#(num1, rest2)) -> {
              case rest2 {
                "," <> rest3 -> {
                  case try_get_number(rest3) {
                    Ok(#(num2, rest4)) -> {
                      case rest4 {
                        ")" <> rest5 -> {
                          parse_iter(rest5, state, [#(num1, num2, state), ..res])
                        }
                        _ -> parse_iter(rest4, state, res)
                      }
                    }
                    Error(_) -> {
                      parse_iter(rest3, state, res)
                    }
                  }
                }
                _ -> parse_iter(rest2, state, res)
              }
            }
            Error(_) -> {
              parse_iter(rest, state, res)
            }
          }
        }
        _ -> parse_iter(string.drop_start(s, 1), state, res)
      }
  }
}

fn parse(s) {
  parse_iter(s, Do, [])
}

pub fn main() {
  let assert Ok(text) = simplifile.read("inputs/day3/input.txt")
  let instructions = parse(text)

  instructions
  |> list.map(fn(p) {
    case p {
      #(a, b, _) -> a * b
    }
  })
  |> int.sum
  |> io.debug

  instructions
  |> list.map(fn(p) {
    case p {
      #(a, b, Do) -> a * b
      #(_, _, Dont) -> 0
    }
  })
  |> int.sum
  |> io.debug
}
