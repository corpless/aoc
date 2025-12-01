import gleam/dict.{type Dict}
import gleam/int
import gleam/io
import gleam/list
import gleam/string
import simplifile

pub type Side {
  Left
  Right
}

pub type Cell {
  Box(side: Side)
  Wall
  Robot
}

pub fn get_other_half(pos: #(Int, Int), side) {
  case side {
    Left -> #(pos.0, pos.1 + 1)
    Right -> #(pos.0, pos.1 - 1)
  }
}

pub fn print_state(positions: Dict(#(Int, Int), Cell)) {
  let n =
    positions
    |> dict.keys
    |> list.map(fn(x) { x.0 })
    |> list.fold(0, int.max)

  let m =
    positions
    |> dict.keys
    |> list.map(fn(x) { x.1 })
    |> list.fold(0, int.max)

  list.range(0, n)
  |> list.map(fn(i) {
    list.range(0, m)
    |> list.map(fn(j) {
      case dict.get(positions, #(i, j)) {
        Ok(Robot) -> "@"
        Ok(Box(Left)) -> "["
        Ok(Box(Right)) -> "]"
        Ok(Wall) -> "#"
        Error(Nil) -> "."
      }
    })
    |> string.join("")
    |> io.println()
  })
}

pub fn try_move(
  positions: Dict(#(Int, Int), Cell),
  pos: #(Int, Int),
  instruction: #(Int, Int),
) {
  let new_pos = #(pos.0 + instruction.0, pos.1 + instruction.1)
  case dict.get(positions, new_pos) {
    Error(Nil) -> {
      let assert Ok(cur_elem) = dict.get(positions, pos)
      let new_positions =
        positions
        |> dict.delete(pos)
        |> dict.insert(new_pos, cur_elem)
      Ok(new_positions)
    }
    Ok(Wall) -> {
      Error(Nil)
    }
    Ok(Box(side)) -> {
      case instruction.0 {
        0 -> {
          // moving horizontally, all stays the same
          case try_move(positions, new_pos, instruction) {
            Ok(new_positions) -> try_move(new_positions, pos, instruction)
            Error(_) -> Error(Nil)
          }
        }
        _ -> {
          // moving the first half
          case try_move(positions, new_pos, instruction) {
            // then moving the second half
            Ok(new_positions) -> {
              case
                try_move(
                  new_positions,
                  get_other_half(new_pos, side),
                  instruction,
                )
              {
                Ok(new_positions2) -> try_move(new_positions2, pos, instruction)
                Error(_) -> Error(Nil)
              }
            }
            Error(_) -> Error(Nil)
          }
        }
      }
    }
    Ok(Robot) -> {
      panic as "unexpected robot"
    }
  }
}

pub fn move_robot(positions, instruction) {
  // io.debug(instruction)
  // print_state(positions)
  let assert [init_robot_pos] =
    positions
    |> dict.filter(fn(_key, value) { value == Robot })
    |> dict.keys
  case try_move(positions, init_robot_pos, instruction) {
    Ok(new_positions) -> new_positions
    Error(Nil) -> positions
  }
}

pub fn get_score(positions: Dict(#(Int, Int), Cell)) {
  positions
  |> dict.to_list
  |> list.map(fn(x) {
    let #(key, value) = x
    case value {
      Box(Left) -> 100 * key.0 + key.1
      _ -> 0
    }
  })
  |> list.fold(0, int.add)
}

pub fn main() {
  let assert Ok(text) = simplifile.read("inputs/day15/input.txt")
  let assert [grid, instructions] = string.split(text, "\n\n")
  let positions =
    grid
    |> string.split("\n")
    |> list.index_map(fn(line, i) {
      line
      |> string.split("")
      |> list.index_map(fn(c, j) {
        case c {
          "@" -> [#(#(i, j * 2), Robot)]
          "#" -> [#(#(i, j * 2), Wall), #(#(i, j * 2 + 1), Wall)]
          "O" -> [#(#(i, j * 2), Box(Left)), #(#(i, j * 2 + 1), Box(Right))]
          "." -> []
          _ -> panic as "unexpected char"
        }
      })
      |> list.flatten
    })
    |> list.flatten
    |> dict.from_list

  let instructions =
    instructions
    |> string.split("")
    |> list.filter(fn(x) { x != "\n" })
    |> list.map(fn(c) {
      case c {
        ">" -> #(0, 1)
        "<" -> #(0, -1)
        "v" -> #(1, 0)
        "^" -> #(-1, 0)
        _ -> panic as { "unexpected insruction " <> c }
      }
    })
  instructions
  |> list.fold(positions, move_robot)
  |> get_score
  |> io.debug
}
