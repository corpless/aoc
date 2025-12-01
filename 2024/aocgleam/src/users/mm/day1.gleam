import gleam/int
import gleam/io
import gleam/list
import gleam/order
import gleam/string
import simplifile

fn two_pointers(left, right, freq, res) {
  case left {
    [] -> res
    [left_head, ..left_tail] ->
      case right {
        [] -> two_pointers(left_tail, right, 0, res + left_head * freq)
        [right_head, ..right_tail] ->
          case int.compare(left_head, right_head) {
            order.Eq -> two_pointers(left, right_tail, freq + 1, res)
            order.Lt -> {
              let next_freq = case left_tail {
                [left_next, ..] ->
                  case left_head == left_next {
                    True -> freq
                    False -> 0
                  }
                [] -> 0
              }
              two_pointers(left_tail, right, next_freq, res + left_head * freq)
            }
            order.Gt -> two_pointers(left, right_tail, 0, res)
          }
      }
  }
}

pub fn main() {
  let assert Ok(text) = simplifile.read("inputs/day1/input.txt")
  let nums =
    text
    |> string.split("\n")
    |> list.filter(fn(x) { x != "" })
    |> list.map(fn(item) {
      item
      |> string.split("   ")
      |> fn(x) {
        case x {
          [a, b] -> #(int.parse(a), int.parse(b))
          _ -> panic as "expected two items in each line"
        }
      }
      |> fn(x) {
        case x {
          #(Ok(a), Ok(b)) -> #(a, b)
          _ -> panic as "invalid int encountered"
        }
      }
    })

  let left =
    nums
    |> list.map(fn(x) { x.0 })
    |> list.sort(int.compare)

  let right =
    nums
    |> list.map(fn(x) { x.1 })
    |> list.sort(int.compare)

  list.zip(left, right)
  |> list.map(fn(x) {
    case x {
      #(a, b) -> int.absolute_value(a - b)
    }
  })
  |> list.fold(0, int.add)
  |> io.debug

  io.debug(two_pointers(left, right, 0, 0))
}
