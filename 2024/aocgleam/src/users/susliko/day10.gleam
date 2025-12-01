import gleam/dict
import gleam/int
import gleam/io
import gleam/list
import gleam/result
import users/susliko/utils

pub fn main() {
  let assert Ok(ints) =
    utils.read_input("inputs/day10/input.txt", "", fn(x) {
      int.parse(x) |> result.unwrap(-1) |> Ok
    })
  let map =
    list.index_map(ints, fn(row, i) {
      let indexed =
        list.index_map(row, fn(el, j) { #(j, el) }) |> dict.from_list
      #(i, indexed)
    })
    |> dict.from_list

  let roots =
    list.index_fold(ints, [], fn(acc, row, i) {
      list.index_fold(row, [], fn(acc, el, j) {
        case el {
          0 -> list.prepend(acc, #(i, j))
          _ -> acc
        }
      })
      |> list.append(acc)
    })

  part1(map, roots) |> io.debug
  part2(map, roots) |> io.debug
}

fn part1(map, roots) {
  roots
  |> list.map(fn(root) {
    let #(i, j) = root
    go(map, i, j, 0)
    |> list.unique
    |> list.length
  })
  |> list.fold(0, int.add)
}

fn part2(map, roots) {
  roots
  |> list.map(fn(root) {
    let #(i, j) = root
    go(map, i, j, 0)
    |> list.length
  })
  |> list.fold(0, int.add)
}

fn go(map, i, j, el) {
  case get(map, i, j) {
    x if x == el -> {
      case el {
        9 -> [#(i, j)]
        _ ->
          list.flatten([
            go(map, i + 1, j, el + 1),
            go(map, i - 1, j, el + 1),
            go(map, i, j + 1, el + 1),
            go(map, i, j - 1, el + 1),
          ])
      }
    }
    _ -> []
  }
}

fn get(map, i, j) {
  map
  |> dict.get(i)
  |> result.unwrap(dict.new())
  |> dict.get(j)
  |> result.unwrap(-1)
}
