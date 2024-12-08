import gleam/dict
import gleam/int
import gleam/io
import gleam/list
import gleam/set
import gleam/string
import simplifile

fn gcd(a, b) {
  case b > a {
    True -> gcd(b, a)
    False ->
      case b {
        0 -> a
        _ -> gcd(b, a % b)
      }
  }
}

fn add_while(i, j, di, dj, n, m, res) {
  let #(new_i, new_j) = #(i + di, j + dj)
  case new_i >= 0 && new_j >= 0 && new_i < n && new_j < m {
    True -> {
      add_while(new_i, new_j, di, dj, n, m, [#(new_i, new_j), ..res])
    }
    False -> res
  }
}

fn get_positions_from_pair1(n, m, ai, aj, bi, bj) {
  let di = ai - bi
  let dj = aj - bj
  [#(ai + di, aj + dj), #(bi - di, bj - dj)]
  |> list.filter(fn(c) {
    let #(i, j) = c
    i >= 0 && j >= 0 && i < n && j < m
  })
}

fn get_positions_from_pair2(n, m, ai, aj, bi, bj) {
  let di = ai - bi
  let dj = aj - bj
  let #(ndi, ndj) = case di, dj {
    0, _ -> #(0, 1)
    _, 0 -> #(1, 0)
    _, _ -> {
      let gcd = gcd(int.absolute_value(di), int.absolute_value(dj))
      #(di / gcd, dj / gcd)
    }
  }
  list.flatten([
    add_while(ai, aj, ndi, ndj, n, m, []),
    add_while(ai, aj, -ndi, -ndj, n, m, []),
    [#(ai, aj)],
  ])
}

fn solve(n, m, grid: List(#(#(Int, Int), Int)), part) {
  grid
  |> list.group(fn(x) { x.1 })
  |> dict.to_list
  |> list.flat_map(fn(x) {
    let #(_c, cells) = x
    cells
    |> list.combination_pairs()
    |> list.flat_map(fn(x) {
      let #(#(#(ai, aj), _ac), #(#(bi, bj), _bc)) = x
      case part {
        One -> get_positions_from_pair1(n, m, ai, aj, bi, bj)
        Two -> get_positions_from_pair2(n, m, ai, aj, bi, bj)
      }
    })
  })
  |> set.from_list
  |> set.size
  |> io.debug
}

type Part {
  One
  Two
}

pub fn main() {
  let assert Ok(text) = simplifile.read("inputs/day8/input.txt")
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
    |> list.filter(fn(x) { x.1 != 46 })

  solve(n, m, grid, One)
  solve(n, m, grid, Two)
}
