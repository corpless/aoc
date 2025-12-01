import gleam/dict
import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/string
import simplifile

const all_directions = [
  #(0, 1), #(0, -1), #(1, 0), #(-1, 0), #(1, 1), #(-1, -1), #(1, -1), #(-1, 1),
]

fn first_step(first_char c, grid g) {
  g
  |> dict.to_list()
  |> list.flat_map(fn(x) {
    let #(#(i, j), v) = x
    case v == c {
      True -> [#(#(i, j), 1)]
      False -> []
    }
  })
}

fn iter2(directions, word, grid, res) {
  let step = fn(expected_char, prev_state) {
    prev_state
    |> list.flat_map(fn(x) {
      let #(#(i, j), c) = x
      list.flat_map(directions, fn(d) {
        let #(di, dj) = d
        case dict.get(grid, #(i + di, j + dj)) {
          Ok(grid_char) if grid_char == expected_char -> [
            #(#(i + di, j + dj), c),
          ]
          _ -> []
        }
      })
    })
    |> list.group(fn(x) { x.0 })
    |> dict.map_values(fn(_key, value) {
      value |> list.map(fn(x) { x.1 }) |> list.fold(0, int.add)
    })
    |> dict.to_list
  }
  case word {
    [] -> res
    [c, ..rest] -> iter2(directions, rest, grid, step(c, res))
  }
}

fn find_words(word, grid, directions) {
  let assert [first, ..rest] = word
  let init_state = first_step(first, grid)
  list.map(directions, fn(direction) {
    let final_state = iter2([direction], rest, grid, init_state)
    #(direction, final_state)
  })
}

const diag_directions = [#(1, 1), #(-1, -1), #(1, -1), #(-1, 1)]

fn find_crosses(grid) {
  let mas = [77, 65, 83]
  let diag_mas_found = find_words(mas, grid, diag_directions) |> dict.from_list
  diag_directions
  |> list.combination_pairs
  |> list.flat_map(fn(x) {
    let #(#(a_di, a_dj), #(b_di, b_dj)) = x
    case a_di == b_di || a_dj == b_dj {
      True -> {
        let a_mas =
          dict.get(diag_mas_found, #(a_di, a_dj))
          |> result.lazy_unwrap(fn() { [] })
        let b_mas =
          dict.get(diag_mas_found, #(b_di, b_dj))
          |> result.lazy_unwrap(fn() { [] })
        a_mas
        |> list.flat_map(fn(a_word) {
          b_mas
          |> list.filter(fn(b_word) {
            let #(#(ai, aj), _) = a_word
            let #(#(bi, bj), _) = b_word
            { { ai - a_di } == { bi - b_di } }
            && { { aj - a_dj } == { bj - b_dj } }
          })
        })
      }
      False -> []
    }
  })
  |> list.length
}

pub fn main() {
  let assert Ok(text) = simplifile.read("inputs/day4/input.txt")
  let grid =
    text
    |> string.split("\n")
    |> list.map(string.to_utf_codepoints)
    |> list.map(fn(line) { list.map(line, string.utf_codepoint_to_int) })
  let n = list.length(grid)
  let m =
    list.length({
      let assert Ok(first) = list.first(grid)
      first
    })
  let g =
    grid
    |> list.zip(list.range(0, n - 1))
    |> list.flat_map(fn(p) {
      let #(line, i) = p
      line
      |> list.zip(list.range(0, m - 1))
      |> list.map(fn(p) {
        let #(char, j) = p
        #(#(i, j), char)
      })
    })
    |> dict.from_list()
  //                 X   M   A   S
  let str_to_find = [88, 77, 65, 83]
  find_words(str_to_find, g, all_directions)
  |> list.flat_map(fn(x) { x.1 })
  |> list.map(fn(x) { x.1 })
  |> list.fold(0, int.add)
  |> io.debug

  find_crosses(g) |> io.debug
}
