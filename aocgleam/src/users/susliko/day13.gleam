import gleam/int
import gleam/io
import gleam/list
import gleam/option
import gleam/regexp
import users/susliko/utils

pub fn main() {
  let assert Ok(blocks) = utils.read_line_blocks("inputs/day13/input.txt")

  let automats =
    list.flat_map(blocks, fn(block) {
      case list.reverse(block) {
        [tgt_str, ..moves_str] -> {
          parse_target(tgt_str)
          |> list.map(fn(tgt) {
            let moves = moves_str |> list.flat_map(parse_move)
            Automat(moves, tgt)
          })
        }
        _ -> []
      }
    })

  estimate(automats) |> io.debug

  automats
  |> list.map(fn(aut) {
    case aut {
      Automat(moves, Pos(i, j)) ->
        Automat(moves, Pos(i + 10_000_000_000_000, j + 10_000_000_000_000))
    }
  })
  |> estimate
  |> io.debug
}

fn estimate(automats: List(Automat)) {
  list.map(automats, fn(aut) {
    let assert [Move("B", Pos(bi, bj)), Move("A", Pos(ai, aj))] = aut.moves
    let tgt_i = aut.tgt.i
    let tgt_j = aut.tgt.j
    let b_divisor = bi * aj - bj * ai
    let b_divident = tgt_i * aj - tgt_j * ai
    let b = b_divident / b_divisor
    let a_divident = tgt_i - b * bi
    case b_divident % b_divisor, a_divident % ai {
      0, 0 -> {
        let a = a_divident / ai
        a * 3 + b
      }
      _, _ -> 0
    }
  })
  |> int.sum
}

pub type Move {
  Move(name: String, go: Pos)
}

pub type Automat {
  Automat(moves: List(Move), tgt: Pos)
}

pub type Pos {
  Pos(i: Int, j: Int)
}

fn parse_move(line) {
  let num = "([-+][0-9]+)"
  let assert Ok(move_re) =
    regexp.from_string("Button ([A-Z]): X" <> num <> ", Y" <> num)
  let match = regexp.scan(move_re, line) |> list.map(fn(m) { m.submatches })
  case match {
    [[option.Some(name), option.Some(x), option.Some(y)]] ->
      case int.parse(x), int.parse(y) {
        Ok(x), Ok(y) -> [Move(name, Pos(x, y))]
        _, _ -> []
      }
    _ -> []
  }
}

fn parse_target(line) {
  let num = "([0-9]+)"
  let assert Ok(move_re) =
    regexp.from_string("Prize: X=" <> num <> ", Y=" <> num)
  let match = regexp.scan(move_re, line) |> list.map(fn(m) { m.submatches })
  case match {
    [[option.Some(x), option.Some(y)]] ->
      case int.parse(x), int.parse(y) {
        Ok(x), Ok(y) -> [Pos(x, y)]
        _, _ -> []
      }
    _ -> []
  }
}
