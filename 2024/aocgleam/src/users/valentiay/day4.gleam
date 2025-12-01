import gleam/dict
import gleam/io
import gleam/list
import gleam/option
import gleam/result
import gleam/string
import users/valentiay/utils

type Matrix =
  dict.Dict(#(Int, Int), String)

type Mas =
  List(#(Int, Int))

const masses = [
  [#(1, 0), #(2, 0), #(3, 0)], [#(-1, 0), #(-2, 0), #(-3, 0)],
  [#(0, 1), #(0, 2), #(0, 3)], [#(0, -1), #(0, -2), #(0, -3)],
  [#(1, 1), #(2, 2), #(3, 3)], [#(1, -1), #(2, -2), #(3, -3)],
  [#(-1, 1), #(-2, 2), #(-3, 3)], [#(-1, -1), #(-2, -2), #(-3, -3)],
]

const pos_x_masses = [
  [#(-1, -1), #(0, 0), #(1, 1)], [#(1, 1), #(0, 0), #(-1, -1)],
]

const neg_x_masses = [
  [#(-1, 1), #(0, 0), #(1, -1)], [#(1, -1), #(0, 0), #(-1, 1)],
]

fn contains_mas(matrix: Matrix, x: Int, y: Int, mas: Mas) -> Bool {
  mas
  |> list.flat_map(fn(coords) {
    let #(rx, ry) = coords
    matrix
    |> dict.get(#(x + rx, y + ry))
    |> result.map(fn(x) { [x] })
    |> result.unwrap([])
  })
  == ["M", "A", "S"]
}

fn count_masses(matrix: Matrix, x: Int, y: Int, masses: List(Mas)) -> Int {
  masses |> list.count(fn(mas) { contains_mas(matrix, x, y, mas) })
}

fn contains_x_mas(matrix: Matrix, x: Int, y: Int) -> Bool {
  let contains_pos = count_masses(matrix, x, y, pos_x_masses) > 0
  let contains_neg = count_masses(matrix, x, y, neg_x_masses) > 0
  contains_pos && contains_neg
}

pub fn main() {
  use str <- result.try(utils.read_string("inputs/day4/input.txt"))
  let lines = str |> string.split("\n")
  let matrix =
    lines
    |> list.index_map(fn(line, y) {
      line
      |> string.to_graphemes
      |> list.index_map(fn(char, x) { #(#(x, y), char) })
    })
    |> list.flatten
    |> dict.from_list

  let ys = list.range(0, list.length(lines) - 1)

  let line_length =
    list.first(lines)
    |> option.from_result
    |> option.map(string.length(_))
    |> option.unwrap(0)

  let xs = list.range(0, line_length - 1)

  xs
  |> list.fold(0, fn(acc, x) {
    let new =
      ys
      |> list.fold(0, fn(acc, y) {
        let c = matrix |> dict.get(#(x, y)) |> result.unwrap("")
        case c {
          "X" -> acc + count_masses(matrix, x, y, masses)
          _ -> acc
        }
      })
    acc + new
  })
  |> io.debug

  xs
  |> list.fold(0, fn(acc, x) {
    let new =
      ys
      |> list.count(fn(y) {
        let c = matrix |> dict.get(#(x, y)) |> result.unwrap("")
        case c {
          "A" -> contains_x_mas(matrix, x, y)
          _ -> False
        }
      })
    acc + new
  })
  |> io.debug

  Ok(0)
}
