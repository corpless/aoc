import gleam/int
import gleam/io
import gleam/list
import gleam/string
import simplifile

fn min_cost(ax, ay, bx, by, tx, ty) {
  let d = ax * by - bx * ay
  case d == 0 {
    True -> Error(Nil)
    False -> {
      let ta = tx * by - bx * ty
      let tb = ax * ty - tx * ay
      case ta % d == 0 && tb % d == 0 {
        True -> {
          let na = ta / d
          let nb = tb / d
          case na > 0 && nb > 0 {
            True -> Ok(3 * na + nb)
            False -> Error(Nil)
          }
        }
        False -> Error(Nil)
      }
    }
  }
}

fn parse_button(s) {
  let assert [_left, right] = string.split(s, "X+")
  let assert [x_str, rest] = string.split(right, ",")
  let assert Ok(x) = int.parse(x_str)
  let assert [_, y_str] = string.split(rest, "Y+")
  let assert Ok(y) = int.parse(y_str)
  #(x, y)
}

fn parse_target(s) {
  let assert [_left, right] = string.split(s, "X=")
  let assert [x_str, rest] = string.split(right, ",")
  let assert Ok(x) = int.parse(x_str)
  let assert [_, y_str] = string.split(rest, "Y=")
  let assert Ok(y) = int.parse(y_str)
  #(x, y)
}

pub fn main() {
  let assert Ok(text) = simplifile.read("inputs/day13/input.txt")
  text
  |> string.split("\n\n")
  |> list.filter_map(fn(block) {
    let assert [a_str, b_str, target] = string.split(block, "\n")
    let #(ax, ay) = parse_button(a_str)
    let #(bx, by) = parse_button(b_str)
    let #(tx, ty) = parse_target(target)
    min_cost(ax, ay, bx, by, tx, ty)
  })
  |> list.fold(0, int.add)
  |> io.debug

  let assert Ok(text) = simplifile.read("inputs/day13/input.txt")
  text
  |> string.split("\n\n")
  |> list.filter_map(fn(block) {
    let assert [a_str, b_str, target] = string.split(block, "\n")
    let #(ax, ay) = parse_button(a_str)
    let #(bx, by) = parse_button(b_str)
    let #(tx, ty) = parse_target(target)
    min_cost(ax, ay, bx, by, 10_000_000_000_000 + tx, 10_000_000_000_000 + ty)
  })
  |> list.fold(0, int.add)
  |> io.debug
}
