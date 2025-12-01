import gleam/dict
import gleam/io
import gleam/list
import gleam/result
import gleam/set
import gleam/string
import users/valentiay/utils

type Vec =
  #(Int, Int)

type Obst =
  dict.Dict(Vec, Bool)

type Vis =
  dict.Dict(Vec, set.Set(Int))

fn move(loc: Vec, dir: Vec) -> Vec {
  #(loc.0 + dir.0, loc.1 + dir.1)
}

fn turn(dir: Vec) -> Vec {
  case dir {
    #(0, -1) -> #(1, 0)
    #(1, 0) -> #(0, 1)
    #(0, 1) -> #(-1, 0)
    _ -> #(0, -1)
  }
}

fn dir_idx(dir: Vec) -> Int {
  case dir {
    #(0, -1) -> 0
    #(1, 0) -> 1
    #(0, 1) -> 2
    _ -> 3
  }
}

fn add_vis_dir(visited: Vis, loc: Vec, dir: Vec) -> Vis {
  let new_vis_dirs =
    visited
    |> dict.get(loc)
    |> result.unwrap(set.new())
    |> set.insert(dir_idx(dir))
  visited |> dict.insert(loc, new_vis_dirs)
}

fn is_already_visited(visited: Vis, loc: Vec, dir: Vec) -> Bool {
  visited
  |> dict.get(loc)
  |> result.unwrap(set.new())
  |> set.contains(dir_idx(dir))
}

fn step(obstacles: Obst, loc: Vec, dir: Vec, visited: Vis) -> Result(Vis, Nil) {
  case is_already_visited(visited, loc, dir) {
    True -> Error(Nil)
    False -> {
      let new_loc = move(loc, dir)
      let new_visited = visited |> add_vis_dir(loc, dir)
      case obstacles |> dict.get(new_loc) {
        Error(_) -> Ok(new_visited)
        Ok(False) -> step(obstacles, new_loc, dir, new_visited)
        Ok(True) -> {
          let new_dir = turn(dir)
          step(obstacles, loc, new_dir, new_visited)
        }
      }
    }
  }
}

fn add_obstacles(
  obstacles: Obst,
  loc: Vec,
  dir: Vec,
  visited: Vis,
  added_obstacles: Obst,
) -> Obst {
  let new_loc = move(loc, dir)
  let new_visited = visited |> add_vis_dir(loc, dir)
  let new_dir = turn(dir)
  case obstacles |> dict.get(new_loc) {
    Error(_) -> added_obstacles
    Ok(False) -> {
      let should_go = visited |> dict.has_key(new_loc) == False
      let new_add_obstacles: Obst = case should_go {
        True ->
          step(obstacles |> dict.insert(new_loc, True), loc, new_dir, visited)
          |> result.map(fn(_) { added_obstacles })
          |> result.unwrap(added_obstacles |> dict.insert(new_loc, True))
        False -> added_obstacles
      }
      add_obstacles(obstacles, new_loc, dir, new_visited, new_add_obstacles)
    }
    Ok(True) -> {
      add_obstacles(obstacles, loc, new_dir, new_visited, added_obstacles)
    }
  }
}

pub fn main() {
  use str <- result.try(utils.read_string("inputs/day6/input.txt"))
  let lines = str |> string.split("\n")
  let chars =
    lines
    |> list.index_map(fn(line, y) {
      line
      |> string.to_graphemes
      |> list.index_map(fn(char, x) { #(#(x, y), char) })
    })
    |> list.flatten
  let chart_dict = chars |> dict.from_list

  let start_loc =
    chars
    |> list.find(fn(item) { item.1 == "^" })
    |> result.map(fn(item) { item.0 })
    |> result.unwrap(#(0, 0))

  let obstacles =
    chart_dict
    |> dict.map_values(fn(_, v) {
      case v {
        "#" -> True
        _ -> False
      }
    })

  step(obstacles, start_loc, #(0, -1), dict.new())
  |> result.unwrap(dict.new())
  |> dict.size
  |> io.debug

  add_obstacles(obstacles, start_loc, #(0, -1), dict.new(), dict.new())
  |> dict.size
  |> io.debug

  Ok(0)
}
