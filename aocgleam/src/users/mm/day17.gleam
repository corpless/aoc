import gleam/int
import gleam/io
import gleam/list

fn get_combo(operand, a, b, c) {
  case operand {
    0 | 1 | 2 | 3 -> operand
    4 -> a
    5 -> b
    6 -> c
    _ -> panic as "invalid combo operand"
  }
}

const debug = True

fn simulate(instructions, a, b, c, i) {
  let program = list.drop(instructions, i)
  case debug {
    True -> {
      //io.debug(#(program, int.to_base2(a), int.to_base2(b), int.to_base2(c)))
      io.debug(#(program, a, b, c))
      Nil
    }
    False -> Nil
  }
  case program {
    [] -> Nil
    [_] -> Nil
    [command, operand, ..] -> {
      case command {
        //adv
        0 -> {
          let combo = get_combo(operand, a, b, c)
          let res = a / int.bitwise_shift_left(1, combo)
          simulate(instructions, res, b, c, i + 2)
        }
        // bxl
        1 -> {
          let res = int.bitwise_exclusive_or(b, operand)
          simulate(instructions, a, res, c, i + 2)
        }
        // bst
        2 -> {
          let combo = get_combo(operand, a, b, c)
          let res = combo % 8
          simulate(instructions, a, res, c, i + 2)
        }
        // jnz
        3 -> {
          case a {
            0 -> simulate(instructions, a, b, c, i + 2)
            _ -> simulate(instructions, a, b, c, operand)
          }
        }
        // bxc
        4 -> {
          let res = int.bitwise_exclusive_or(b, c)
          simulate(instructions, a, res, c, i + 2)
        }
        // out
        5 -> {
          let combo = get_combo(operand, a, b, c)
          let res = combo % 8
          case debug {
            True -> {
              io.debug(#("output", res))
              Nil
            }
            False -> {
              io.print(int.to_string(res))
              io.print(",")
            }
          }
          simulate(instructions, a, b, c, i + 2)
        }
        // bdv
        6 -> {
          let combo = get_combo(operand, a, b, c)
          simulate(instructions, a, combo, c, i + 2)
        }
        // cdv
        7 -> {
          let combo = get_combo(operand, a, b, c)
          let res = a / int.bitwise_shift_left(1, combo)
          simulate(instructions, a, b, res, i + 2)
        }
        _ -> panic as "unexpected opcode"
      }
    }
  }
}

pub fn main() {
  // io.println("expecting 0,1,2")
  // simulate([5, 0, 5, 1, 5, 4], 10, 0, 0, 0)
  // io.println("expecting 4,2,5,6,7,7,7,7,3,1,0")
  //simulate([1, 7], 0, 29, 0, 0)
  // simulate([4, 0], 0, 2024, 43_690, 0)
  // simulate([0, 1, 5, 4, 3, 0], 2024, 0, 0, 0)
  //simulate([0, 1, 5, 4, 3, 0], 729, 0, 0, 0)
  simulate([2, 4, 1, 1, 7, 5, 1, 5, 4, 0, 5, 5, 0, 3, 3, 0], 1978, 0, 0, 0)
}
