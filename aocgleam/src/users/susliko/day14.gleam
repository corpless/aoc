import gleam/dict.{type Dict}
import gleam/function
import gleam/int
import gleam/io
import gleam/list
import gleam/option
import gleam/order
import gleam/regexp
import gleam/result
import gleam/set
import gleam/string
import users/susliko/utils

pub fn main() {
  let assert Ok(raw) = utils.read_lines("inputs/day14/input.txt")
  // let xmax = 11
  // let ymax = 7
  let xmax = 101
  let ymax = 103

  let num = "([-+0-9]+)"
  let assert Ok(re) =
    regexp.from_string("p=" <> num <> "," <> num <> " v=" <> num <> "," <> num)

  let robots =
    list.flat_map(raw, fn(line) {
      let m =
        regexp.scan(re, line)
        |> list.flat_map(fn(m) {
          m.submatches |> option.values |> list.map(int.parse) |> result.values
        })
      case m {
        [x, y, vx, vy] -> [Robot(x, y, vx, vy)]
        _ -> []
      }
    })

  part1(robots, xmax, ymax) |> io.debug
  part2(robots, xmax, ymax)
}

fn part1(robots, xmax, ymax) {
  iterate(robots, 100, xmax, ymax)
  |> get_clusters(xmax, ymax)
  |> list.fold(1, fn(acc, el) { acc * el })
}

fn part2(robots, xmax, ymax) {
  let start = 0
  let steps = 10_000
  let start_robots = iterate(robots, start, xmax, ymax)
  list.range(1, steps)
  |> list.fold(start_robots, fn(robots, i) {
    let robots1 = iterate(robots, 1, xmax, ymax)
    let coord_set = robots1 |> list.map(fn(r) { #(r.x, r.y) }) |> set.from_list
    let is_candidate = set.size(coord_set) == list.length(robots1)
    case is_candidate {
      True -> {
        draw(robots1, xmax, ymax) |> io.println
        io.println(int.to_string(start + i))
      }
      False -> Nil
    }
    robots1
  })
}

fn get_clusters(robots: List(Robot), xmax, ymax) {
  robots
  |> list.map(fn(r) {
    let xmid = xmax / 2
    let ymid = ymax / 2
    case int.compare(r.x, xmid), int.compare(r.y, ymid) {
      order.Eq, _ | _, order.Eq -> Error(Nil)
      order.Lt, order.Lt -> Ok(1)
      order.Gt, order.Lt -> Ok(2)
      order.Lt, order.Gt -> Ok(3)
      order.Gt, order.Gt -> Ok(4)
    }
  })
  |> result.values
  |> list.group(function.identity)
  |> dict.values
  |> list.map(fn(l) { list.length(l) })
}

fn iterate(robots: List(Robot), steps, xmax, ymax) {
  robots
  |> list.map(fn(r) {
    let x1 = { { r.x + r.vx * steps } % xmax + xmax } % xmax
    let y1 = { { r.y + r.vy * steps } % ymax + ymax } % ymax
    Robot(x1, y1, r.vx, r.vy)
  })
}

fn draw(robots: List(Robot), xmax, ymax) {
  let line =
    list.repeat(0, xmax)
    |> list.index_map(fn(el, i) { #(i, el) })
    |> dict.from_list
  let map =
    list.repeat(line, ymax)
    |> list.index_map(fn(el, j) { #(j, el) })
    |> dict.from_list

  let robot_map: Dict(Int, Dict(Int, Int)) =
    list.fold(robots, map, fn(acc, r) {
      dict.upsert(acc, r.y, fn(opt_line) {
        let line = option.unwrap(opt_line, dict.new())
        dict.upsert(line, r.x, fn(opt_el) { option.unwrap(opt_el, 0) + 1 })
      })
    })

  robot_map
  |> dict.map_values(fn(_, line) {
    dict.to_list(line)
    |> list.sort(fn(a, b) { int.compare(a.0, b.0) })
    |> list.map(fn(el) {
      case el {
        #(_, 0) -> "."
        #(_, i) -> int.to_string(i)
      }
    })
    |> string.concat
  })
  |> dict.to_list
  |> list.sort(fn(a, b) { int.compare(a.0, b.0) })
  |> list.map(fn(el) { el.1 })
  |> string.join("\n")
}

pub type Robot {
  Robot(x: Int, y: Int, vx: Int, vy: Int)
}
