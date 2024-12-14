import gleam/dict
import gleam/int
import gleam/io
import gleam/list
import gleam/set
import users/susliko/utils

pub fn main() {
  let assert Ok(plants) = utils.read_chars("inputs/day12/input.txt")

  let tuples =
    plants
    |> list.index_map(fn(row, i) {
      list.index_map(row, fn(el, j) { #(#(i, j), el) })
    })
    |> list.flatten

  let map = dict.from_list(tuples)

  part1(tuples, map) |> io.debug
  part2(tuples, map) |> io.debug
}

fn part1(tuples, map) {
  find_regions(tuples, map)
  |> list.map(fn(reg) { find_perim(reg) * set.size(reg) })
  |> int.sum
}

fn part2(tuples, map) {
  find_regions(tuples, map)
  |> list.map(fn(reg) { find_sides(reg) * set.size(reg) })
  |> int.sum
}

fn find_sides(region) {
  // Shameless code theft
  let direction_pairs = [
    #(#(0, 1), #(1, 0)),
    #(#(1, 0), #(0, -1)),
    #(#(0, -1), #(-1, 0)),
    #(#(-1, 0), #(0, 1)),
  ]
  region
  |> set.to_list
  |> list.map(fn(p: #(Int, Int)) {
    list.count(direction_pairs, fn(dir_pair) {
      let #(d1, d2) = dir_pair
      let first_neighbor = set.contains(region, #(p.0 + d1.0, p.1 + d1.1))
      let second_neighbor = set.contains(region, #(p.0 + d2.0, p.1 + d2.1))
      let corner = set.contains(region, #(p.0 + d1.0 + d2.0, p.1 + d1.1 + d2.1))
      { !first_neighbor && !second_neighbor }
      || { first_neighbor && second_neighbor && !corner }
    })
  })
  |> int.sum
}

fn find_perim(region) {
  let neibs = fn(i, j) { [#(i - 1, j), #(i + 1, j), #(i, j - 1), #(i, j + 1)] }
  region
  |> set.to_list
  |> list.map(fn(el) {
    let #(i, j) = el
    neibs(i, j)
    |> list.count(fn(el) { !set.contains(region, el) })
  })
  |> int.sum
}

fn find_regions(tuples, map) {
  let #(_, regions) =
    tuples
    |> list.fold(#(set.new(), []), fn(acc, t) {
      let #(visited, regs) = acc
      let #(#(i, j), flower) = t
      case set.contains(visited, #(i, j)) {
        False -> {
          let reg = dfs(i, j, flower, map, set.new())
          #(set.union(visited, reg), [reg, ..regs])
        }
        True -> acc
      }
    })
  regions
}

fn dfs(i, j, flower, map, visited) {
  case set.contains(visited, #(i, j)) {
    True -> visited
    False -> {
      let visited1 = set.insert(visited, #(i, j))
      [#(i - 1, j), #(i + 1, j), #(i, j - 1), #(i, j + 1)]
      |> list.fold(visited1, fn(visited, step) {
        let #(i1, j1) = step
        case dict.get(map, #(i1, j1)) {
          Ok(flower2) if flower2 == flower -> dfs(i1, j1, flower2, map, visited)
          _ -> visited
        }
      })
    }
  }
}
