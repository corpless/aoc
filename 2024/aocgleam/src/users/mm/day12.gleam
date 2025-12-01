import gleam/dict
import gleam/int
import gleam/io
import gleam/list
import gleam/option.{None, Some}
import gleam/set.{type Set}
import gleam/string
import simplifile

const directions: List(#(Int, Int)) = [#(1, 0), #(-1, 0), #(0, 1), #(0, -1)]

fn dfs(
  all_points: Set(#(Int, Int)),
  stack: List(#(Int, Int)),
  points_visited: Set(#(Int, Int)),
) {
  case stack {
    [] -> points_visited
    [head, ..tail] -> {
      let points_visited = set.insert(points_visited, head)
      let possible_children =
        list.map(directions, fn(d) { #(head.0 + d.0, head.1 + d.1) })
      let children_to_visit =
        list.filter(possible_children, fn(c) {
          set.contains(all_points, c) && !set.contains(points_visited, c)
        })
      dfs(all_points, list.append(children_to_visit, tail), points_visited)
    }
  }
}

fn find_groups(remaining_points, res) {
  case set.to_list(remaining_points) {
    [] -> res
    [head, ..tail] -> {
      let point_set = set.from_list(tail)
      let points_visited = dfs(point_set, [head], set.new())
      find_groups(set.difference(point_set, points_visited), [
        points_visited,
        ..res
      ])
    }
  }
}

pub fn main() {
  let assert Ok(text) = simplifile.read("inputs/day12/sample.txt")
  let grid =
    text
    |> string.split("\n")
    |> list.filter(fn(l) { l != "" })
    |> list.map(fn(l) { string.split(l, "") })
    |> list.index_map(fn(line, i) {
      list.index_map(line, fn(h, j) { #(h, #(i, j)) })
    })
    |> list.flatten
    |> list.fold(dict.new(), fn(d, cell) {
      let #(h, pos) = cell
      dict.upsert(d, h, fn(old_pos) {
        case old_pos {
          Some(pos_arr) -> [pos, ..pos_arr]
          None -> [pos]
        }
      })
    })
    |> dict.values

  let groups = list.flat_map(grid, fn(x) { find_groups(set.from_list(x), []) })
  groups
  |> list.map(fn(g) {
    g
    |> set.to_list
    |> list.map(fn(p) {
      list.count(directions, fn(d) { !set.contains(g, #(p.0 + d.0, p.1 + d.1)) })
    })
  })
  |> list.map(fn(l) { list.length(l) * list.fold(l, 0, int.add) })
  |> list.fold(0, int.add)
  |> io.debug

  let direction_pairs = [
    #(#(0, 1), #(1, 0)),
    #(#(1, 0), #(0, -1)),
    #(#(0, -1), #(-1, 0)),
    #(#(-1, 0), #(0, 1)),
  ]
  groups
  |> list.map(fn(g) {
    g
    |> set.to_list
    |> list.map(fn(p) {
      list.count(direction_pairs, fn(dir_pair) {
        let #(d1, d2) = dir_pair
        let first_neighbour = set.contains(g, #(p.0 + d1.0, p.1 + d1.1))
        let second_neighbour = set.contains(g, #(p.0 + d2.0, p.1 + d2.1))
        let corner = set.contains(g, #(p.0 + d1.0 + d2.0, p.1 + d1.1 + d2.1))
        // corner pointing outside
        { !first_neighbour && !second_neighbour }
        // corner pointing inside
        || { first_neighbour && second_neighbour && !corner }
      })
    })
  })
  |> list.map(fn(l) { list.length(l) * list.fold(l, 0, int.add) })
  |> list.fold(0, int.add)
  |> io.debug
}
