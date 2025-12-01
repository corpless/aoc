import gleam/dict
import gleam/int
import gleam/io
import gleam/list
import gleam/set
import gleam/string
import simplifile

fn get_final_pos(x, dx, n, n_steps) {
  case n_steps {
    0 -> x
    _ -> {
      let nx = x + dx
      let nx = case nx < 0 {
        True -> n + nx
        False -> nx
      }
      let nx = nx % n
      get_final_pos(nx, dx, n, n_steps - 1)
    }
  }
}

fn get_quadrant(fx, fy, n, m) {
  let x_mid = n / 2
  let y_mid = m / 2
  case fx == x_mid || fy == y_mid {
    True -> Error(Nil)
    False -> {
      let qx = case fx > x_mid {
        True -> 1
        False -> 0
      }
      let qy = case fy > y_mid {
        True -> 1
        False -> 0
      }
      Ok(2 * qx + qy)
    }
  }
}

fn simulate(positions: List(#(Int, Int, Int, Int)), n, m, step) {
  case step {
    10_000 -> positions
    _ -> {
      let positions =
        positions
        |> list.map(fn(x) {
          let #(px, py, vx, vy) = x
          let nx = get_final_pos(px, vx, 101, 1)
          let ny = get_final_pos(py, vy, 103, 1)
          #(nx, ny, vx, vy)
        })
      let y_positions = list.map(positions, fn(p) { p.0 })
      let variance =
        y_positions
        |> list.combination_pairs
        |> list.map(fn(y) { { y.0 - y.1 } * { y.0 - y.1 } })
        |> list.fold(0, int.add)
      case variance <= 86_018_476 {
        True -> {
          io.debug(#(step, variance))

          let pos_dict =
            positions
            |> list.map(fn(x) { #(x.0, x.1) })
            |> set.from_list

          io.debug(step)
          list.range(0, n - 1)
          |> list.map(fn(i) {
            list.range(0, m - 1)
            |> list.map(fn(j) {
              case set.contains(pos_dict, #(j, i)) {
                True -> "#"
                False -> "."
              }
            })
            |> string.join("")
            |> io.println
          })
          Nil
        }
        False -> Nil
      }
      simulate(positions, n, m, step + 1)
    }
  }
}

pub fn main() {
  let assert Ok(text) = simplifile.read("inputs/day14/input.txt")

  let init_positions =
    text
    |> string.split("\n")
    |> list.filter(fn(x) { x != "" })
    |> list.map(fn(line) {
      let assert [p, v] = string.split(line, " ")
      let p = string.drop_start(p, 2)
      let assert [px, py] = string.split(p, ",")
      let assert Ok(px) = int.parse(px)
      let assert Ok(py) = int.parse(py)
      let v = string.drop_start(v, 2)
      let assert [vx, vy] = string.split(v, ",")
      let assert Ok(vx) = int.parse(vx)
      let assert Ok(vy) = int.parse(vy)
      #(px, py, vx, vy)
    })

  init_positions
  |> list.filter_map(fn(x) {
    let #(px, py, vx, vy) = x
    let fx = get_final_pos(px, vx, 101, 100)
    let fy = get_final_pos(py, vy, 103, 100)
    get_quadrant(fx, fy, 101, 103)
  })
  |> list.group(fn(x) { x })
  |> dict.map_values(fn(_key, x) { list.length(x) })
  |> dict.values
  |> list.fold(1, int.multiply)
  |> io.debug

  simulate(init_positions, 101, 103, 0)
}
