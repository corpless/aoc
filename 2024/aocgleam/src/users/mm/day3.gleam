import gleam/int
import gleam/io
import gleam/list
import gleam/string
import simplifile

fn try_get_number(s) {
  let assert Ok(zero_codepoint) = "0" |> string.to_utf_codepoints |> list.first
  let zero = string.utf_codepoint_to_int(zero_codepoint)
  let assert Ok(nine_codepoint) = "9" |> string.to_utf_codepoints |> list.first
  let nine = string.utf_codepoint_to_int(nine_codepoint)
  let ti = fn(i) { i - zero }
  case s {
    [first, second, third, ..rest]
      if first >= zero
      && first <= nine
      && second >= zero
      && second <= nine
      && third >= zero
      && third <= nine
    -> Ok(#(100 * ti(first) + 10 * ti(second) + ti(third), rest))
    [first, second, ..rest]
      if first >= zero && first <= nine && second >= zero && second <= nine
    -> Ok(#(10 * ti(first) + ti(second), rest))
    [first, ..rest] if first >= zero && first <= nine -> Ok(#(ti(first), rest))
    _ -> Error(Nil)
  }
}

type State {
  Do
  Dont
}

fn parse_iter(s, state, res) {
  case s {
    [] -> res
    // do() 
    [100, 111, 40, 41, ..rest] -> parse_iter(rest, Do, res)
    // don't()
    [100, 111, 110, 39, 116, 40, 41, ..rest] -> parse_iter(rest, Dont, res)
    // mul(
    [109, 117, 108, 40, ..rest] -> {
      case try_get_number(rest) {
        Ok(#(num1, rest2)) -> {
          case rest2 {
            // `,` character
            [44, ..rest3] -> {
              case try_get_number(rest3) {
                Ok(#(num2, rest4)) -> {
                  case rest4 {
                    // `)` character
                    [41, ..rest5] -> {
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
    _ -> parse_iter(list.drop(s, 1), state, res)
  }
}

fn parse(s) {
  s
  |> string.to_utf_codepoints
  |> list.map(string.utf_codepoint_to_int)
  |> parse_iter(Do, [])
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
