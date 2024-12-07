import gleam/int
import gleam/io
import gleam/list
import gleam/order
import gleam/set
import gleam/string
import simplifile

fn change_dir(pos: #(Int, Int), dir: #(Int, Int), obstacles) {
  let expected_pos = #(pos.0 + dir.0, pos.1 + dir.1)
  case set.contains(obstacles, expected_pos) {
    False -> dir
    True -> {
      let new_dir = case dir {
        #(1, 0) -> #(0, -1)
        #(-1, 0) -> #(0, 1)
        #(0, 1) -> #(1, 0)
        #(0, -1) -> #(-1, 0)
        _ -> panic as "invalid dir"
      }
      change_dir(pos, new_dir, obstacles)
    }
  }
}

type TraverseResult {
  Finished(steps: set.Set(#(Int, Int)))
  Looped
}

fn iter(n, m, pos: #(Int, Int), dir: #(Int, Int), obstacles, seen) {
  case set.contains(seen, #(pos, dir)) {
    True -> Looped
    False -> {
      let #(i, j) = pos
      case i < 0 || j < 0 || i >= n || j >= m {
        True ->
          seen
          |> set.map(fn(x: #(#(Int, Int), #(Int, Int))) { x.0 })
          |> Finished
        False -> {
          let new_dir = change_dir(pos, dir, obstacles)
          let new_pos = #(i + new_dir.0, j + new_dir.1)
          iter(n, m, new_pos, new_dir, obstacles, set.insert(seen, #(pos, dir)))
        }
      }
    }
  }
}

pub fn main() {
  let assert Ok(text) = simplifile.read("inputs/day6/input.txt")
  let lines = string.split(text, "\n")
  let n = list.length(lines) - 1
  let m = {
    let assert Ok(l) = list.first(lines)
    string.length(l)
  }
  let grid =
    lines
    |> list.index_map(fn(line, i) {
      line
      |> string.to_utf_codepoints()
      |> list.map(string.utf_codepoint_to_int)
      |> list.index_map(fn(c, j) { #(#(i, j), c) })
    })
    |> list.flatten

  let assert Ok(#(start_pos, _c)) =
    grid |> list.filter(fn(x) { x.1 == 94 }) |> list.first()

  let obstacles =
    grid
    |> list.filter_map(fn(x) {
      let #(#(i, j), c) = x
      case c {
        35 -> Ok(#(i, j))
        _ -> Error(Nil)
      }
    })
    |> set.from_list

  let assert Finished(steps) =
    iter(n, m, start_pos, #(-1, 0), obstacles, set.new())
  steps
  |> set.size
  |> io.debug
  // list.range(0, n - 1)
  // |> list.map(fn(i) {
  //   list.range(0, m - 1)
  //   |> list.map(fn(j) {
  //     let pos = #(i, j)
  //     case set.contains(obstacles, pos) {
  //       True -> 35
  //       False -> {
  //         case set.contains(steps, pos) {
  //           True -> 88
  //           False -> 46
  //         }
  //       }
  //     }
  //   })
  //   |> list.map(fn(i) {
  //     let assert Ok(c) = string.utf_codepoint(i)
  //     c
  //   })
  //   |> string.from_utf_codepoints
  //   |> io.println
  // })

  steps
  |> set.to_list
  |> list.filter(fn(step) {
    let #(i, j) = step
    let new_obstacles = set.insert(obstacles, #(i, j))
    case iter(n, m, start_pos, #(-1, 0), new_obstacles, set.new()) {
      Looped -> True
      _ -> False
    }
  })
  |> list.length
  |> io.debug
}
