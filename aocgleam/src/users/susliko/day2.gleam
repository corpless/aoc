import gleam/io
import gleam/list
import users/susliko/utils

pub fn main() {
  let assert Ok(data) = utils.read_ints("inputs/day2/input.txt")
  part1(data) |> io.debug
}

fn part1(data: List(List(Int))) {
  list.count(data, fn(row) {
    case row {
      [_, ..rowtail] -> {
        let nice_pair = fn(a, b) { a - b >= 1 && a - b <= 3 }
        let pairs = list.zip(row, rowtail)
        list.all(pairs, fn(p) { nice_pair(p.0, p.1) })
        || list.all(pairs, fn(p) { nice_pair(p.1, p.0) })
      }
      _ -> True
    }
  })
}
