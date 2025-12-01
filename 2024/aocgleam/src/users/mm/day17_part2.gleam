import gleam/int
import gleam/io
import gleam/list.{Continue, Stop}

pub fn get_out_number(a) {
  let b = int.bitwise_exclusive_or(a % 8, 1)
  //io.debug(b)
  let c = a / int.bitwise_shift_left(1, b)
  //io.debug(c)
  let b = int.bitwise_exclusive_or(b, 5)
  //io.debug(b)
  let b = int.bitwise_exclusive_or(b, c)
  //io.debug(b)
  b % 8
}

pub fn find_a(program, cur_number) {
  io.debug(#(program, cur_number))
  case program {
    [] -> Ok(cur_number)
    [head, ..tail] -> {
      case get_out_number(cur_number) == head {
        False -> Error(Nil)
        True -> {
          list.range(0, 7)
          |> list.fold_until(Error(Nil), fn(_acc, try_digit) {
            let new_number = cur_number * 8 + try_digit
            case find_a(tail, new_number) {
              Ok(number) -> Stop(Ok(number))
              Error(Nil) -> Continue(Error(Nil))
            }
          })
        }
      }
    }
  }
}

pub fn main() {
  //get_out_number(64_854_237) |> io.debug
  find_a(list.reverse([2, 4, 1, 1, 7, 5, 1, 5, 4, 0, 5, 5, 0, 3, 3, 0]), 4)
  |> io.debug
}
