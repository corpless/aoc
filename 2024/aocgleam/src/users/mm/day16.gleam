import gleam/dict.{type Dict}
import gleam/int
import gleam/io
import gleam/list
import gleam/option
import gleam/result
import gleam/set.{type Set}
import gleam/string
import simplifile

pub type Pos {
  Pos(x: Int, y: Int)
}

pub type Dir {
  Dir(dx: Int, dy: Int)
}

const all_dirs = [Dir(1, 0), Dir(0, 1), Dir(-1, 0), Dir(0, -1)]

pub type State {
  State(pos: Pos, dir: Dir)
}

pub type Cell {
  Wall
  Start
  End
  Empty
}

fn get_neighbours(state: State, dist) {
  [
    #(
      State(
        Pos(state.pos.x + state.dir.dx, state.pos.y + state.dir.dy),
        state.dir,
      ),
      dist + 1,
    ),
    #(State(state.pos, Dir(-state.dir.dy, state.dir.dx)), dist + 1000),
    #(State(state.pos, Dir(state.dir.dy, -state.dir.dx)), dist + 1000),
  ]
}

fn find_path(
  q: Set(State),
  dist: Dict(State, Int),
  grid: Dict(Pos, Cell),
  prev: Dict(State, Set(State)),
) {
  let steps_left = set.size(q)
  case steps_left % 1000 == 0 {
    True -> {
      io.debug(steps_left)
      Nil
    }
    False -> Nil
  }
  let q_with_distances =
    q
    |> set.to_list
    |> list.filter_map(fn(s) {
      case dict.get(dist, s) {
        Ok(d) -> Ok(#(s, d))
        Error(Nil) -> Error(Nil)
      }
    })
  case q_with_distances {
    [] -> #(dist, prev)
    [head, ..tail] -> {
      let #(min_state, min_dist) =
        list.fold(tail, head, fn(a, b) {
          case a.1 > b.1 {
            True -> b
            False -> a
          }
        })
      let possible_steps =
        get_neighbours(min_state, min_dist)
        |> list.filter(fn(x) { dict.get(grid, { x.0 }.pos) != Ok(Wall) })

      let strictly_less =
        possible_steps
        |> list.filter(fn(x) {
          let #(new_state, new_dist) = x
          case dict.get(dist, new_state) {
            Error(Nil) -> True
            Ok(old_dist) -> new_dist < old_dist
          }
        })
      let equal =
        possible_steps
        |> list.filter(fn(x) {
          let #(new_state, new_dist) = x
          case dict.get(dist, new_state) {
            Error(Nil) -> True
            Ok(old_dist) -> new_dist == old_dist
          }
        })
      let dist = dict.merge(dist, dict.from_list(strictly_less))
      // if found a shorter path, overwrite prev
      let prev =
        list.fold(strictly_less, prev, fn(prev, update) {
          dict.insert(prev, update.0, set.from_list([min_state]))
        })
      // if found an equal path, add to prev
      let prev =
        list.fold(equal, prev, fn(prev, update) {
          dict.upsert(prev, update.0, fn(old_value) {
            case old_value {
              option.None -> set.from_list([min_state])
              option.Some(old_set) -> set.insert(old_set, min_state)
            }
          })
        })
      let q = set.delete(q, min_state)
      find_path(q, dist, grid, prev)
    }
  }
}

fn reverse_pass(
  q: List(State),
  prev: Dict(State, Set(State)),
  states_visited: Set(State),
) {
  case q {
    [] -> states_visited
    [head, ..tail] -> {
      let states_visited = set.insert(states_visited, head)
      let prev_states =
        dict.get(prev, head)
        |> result.lazy_unwrap(fn() { set.new() })
        |> set.to_list
      reverse_pass(list.flatten([prev_states, tail]), prev, states_visited)
    }
  }
}

pub fn print_tiles(tiles: Set(Pos)) {
  let n =
    tiles
    |> set.to_list
    |> list.map(fn(p) { p.x })
    |> list.fold(0, int.max)

  let m =
    tiles
    |> set.to_list
    |> list.map(fn(p) { p.y })
    |> list.fold(0, int.max)

  list.range(0, n)
  |> list.map(fn(i) {
    list.range(0, m)
    |> list.map(fn(j) {
      case set.contains(tiles, Pos(i, j)) {
        True -> "O"
        False -> "."
      }
    })
    |> string.join("")
    |> io.println()
  })
}

pub fn main() {
  let assert Ok(text) = simplifile.read("inputs/day16/sample.txt")
  let grid =
    text
    |> string.split("\n")
    |> list.index_map(fn(line, i) {
      line
      |> string.split("")
      |> list.index_map(fn(c, j) {
        case c {
          "S" -> [#(Pos(i, j), Start)]
          "#" -> [#(Pos(i, j), Wall)]
          "E" -> [#(Pos(i, j), End)]
          "." -> [#(Pos(i, j), Empty)]
          _ -> panic as "unexpected char"
        }
      })
      |> list.flatten
    })
    |> list.flatten
    |> dict.from_list

  let assert [start_pos] =
    grid
    |> dict.filter(fn(_key, value) { value == Start })
    |> dict.keys

  let all_states =
    grid
    |> dict.filter(fn(_key, value) { value != Wall })
    |> dict.keys
    |> list.flat_map(fn(pos) { list.map(all_dirs, fn(dir) { State(pos, dir) }) })
    |> set.from_list

  let init_state = State(start_pos, Dir(0, 1))
  let #(dist, prev) =
    find_path(all_states, dict.from_list([#(init_state, 0)]), grid, dict.new())
  let assert Ok(#(end_state, end_dist)) =
    dist
    |> dict.filter(fn(key, _value) { dict.get(grid, key.pos) == Ok(End) })
    |> dict.to_list
    |> list.reduce(fn(a, b) {
      case a.1 < b.1 {
        True -> a
        False -> b
      }
    })
  io.debug(end_dist)
  reverse_pass([end_state], prev, set.new())
  |> set.map(fn(x) { x.pos })
  //|> print_tiles
  |> set.to_list
  |> list.length
  |> io.debug()
}
