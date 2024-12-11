import gleam/int
import gleam/io
import gleam/list
import gleam/string
import rememo/memo
import simplifile

pub fn calc(i i, steps_left steps_left) {
  case steps_left {
    0 -> 1
    _ ->
      case i {
        0 -> calc(1, steps_left - 1)
        _ -> {
          let s = int.to_string(i)
          let l = string.length(s)
          case l % 2 == 0 {
            True -> {
              let assert Ok(i1) = int.parse(string.slice(s, 0, l / 2))
              let assert Ok(i2) = int.parse(string.slice(s, l / 2, l / 2))
              calc(i1, steps_left - 1) + calc(i2, steps_left - 1)
            }
            False -> calc(i * 2024, steps_left - 1)
          }
        }
      }
  }
}

pub fn calc_memo(i, steps_left, cache) {
  use <- memo.memoize(cache, #(i, steps_left))
  calc(i, steps_left)
}

pub fn main() {
  let assert Ok(text) = simplifile.read("inputs/day11/input.txt")
  let nums =
    text
    |> string.trim
    |> string.split(" ")
    |> list.map(fn(num) {
      let assert Ok(i) = int.parse(num)
      i
    })

  nums
  |> list.map(fn(x) {
    use cache <- memo.create()
    calc_memo(x, 75, cache)
  })
  |> list.fold(0, int.add)
  |> io.debug
}
