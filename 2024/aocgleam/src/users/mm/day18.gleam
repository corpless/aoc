import gleam/int
import gleam/io
import gleam/list
import gleam/order
import gleam/set
import gleam/string
import simplifile

pub opaque type Queue(a) {
  Queue(front: List(a), back: List(a))
}

pub fn q_new() {
  Queue([], [])
}

pub fn q_push(q: Queue(a), elem: a) {
  Queue(q.front, [elem, ..q.back])
}

pub fn q_pop(q: Queue(a)) {
  case q.front {
    [head, ..tail] -> Ok(#(head, Queue(tail, q.back)))
    [] -> {
      let new_front = list.reverse(q.back)
      case new_front {
        [head, ..tail] -> Ok(#(head, Queue(tail, [])))
        [] -> Error(Nil)
      }
    }
  }
}

pub fn to_set(q: Queue(a)) {
  list.flatten([q.front, q.back]) |> set.from_list
}

const directions = [#(1, 0), #(-1, 0), #(0, 1), #(0, -1)]

pub fn bfs(q, n, seen, obstacles) {
  case q_pop(q) {
    Ok(#(#(depth, head), rest)) -> {
      //io.debug(#(head, rest))
      case head == #(n - 1, n - 1) {
        True -> Ok(depth)
        False -> {
          case set.contains(seen, head) {
            True -> bfs(rest, n, seen, obstacles)
            False -> {
              let new_seen = set.insert(seen, head)
              let new_q =
                directions
                |> list.map(fn(d) { #(head.0 + d.0, head.1 + d.1) })
                |> list.filter(fn(p) {
                  p.0 >= 0
                  && p.0 < n
                  && p.1 >= 0
                  && p.1 < n
                  && !set.contains(obstacles, p)
                })
                //|> io.debug
                |> list.fold(rest, fn(q, elem) { q_push(q, #(depth + 1, elem)) })
              bfs(new_q, n, new_seen, obstacles)
            }
          }
        }
      }
    }
    Error(Nil) -> {
      //print_state(obstacles, seen, n)
      Error(Nil)
    }
  }
}

pub fn print_state(obstacles, path, n) {
  //let path = set.from_list(path)
  list.range(0, n - 1)
  |> list.map(fn(j) {
    list.range(0, n - 1)
    |> list.map(fn(i) {
      case set.contains(obstacles, #(i, j)) {
        True -> "#"
        False ->
          case set.contains(path, #(i, j)) {
            True -> "*"
            False -> " "
          }
      }
    })
    |> string.join("")
    |> io.println()
  })
}

pub fn part2(obstacles, n, i) {
  case
    bfs(
      q_push(q_new(), #(0, #(0, 0))),
      n,
      set.new(),
      obstacles |> list.take(i) |> set.from_list,
    )
  {
    Ok(_) -> part2(obstacles, n, i + 1)
    Error(_) -> i
  }
}

pub fn main() {
  let assert Ok(text) = simplifile.read("inputs/day18/sample.txt")
  let n = 71
  let obstacles =
    text
    |> string.split("\n")
    |> list.filter(fn(x) { x != "" })
    |> list.map(fn(line) {
      let assert [x, y] = string.split(line, ",")
      let assert Ok(x) = int.parse(x)
      let assert Ok(y) = int.parse(y)
      #(x, y)
    })

  bfs(
    q_push(q_new(), #(0, #(0, 0))),
    n,
    set.new(),
    obstacles |> list.take(1024) |> set.from_list,
  )
  |> io.debug

  let i = part2(obstacles, n, 1025) |> io.debug
  obstacles |> list.drop(i - 1) |> list.first() |> io.debug
  //print_state(obstacles, path, n)
}
