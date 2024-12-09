import gleam/int
import gleam/io
import gleam/list
import gleam/order
import gleam/result
import gleam/string
import simplifile

pub type Block {
  Empty(len: Int)
  Data(len: Int, id: Int)
}

pub fn split_list(l) {
  let half = list.length(l) / 2
  let #(left, right) = list.split(l, half)
  #(left, list.reverse(right))
}

pub type PopResult {
  NoElements
  Last(block: Block)
  Both(left: Block, right: Block)
}

pub fn pop_from_double_list(forward, reverse) {
  case forward, reverse {
    [], [] -> #(NoElements, [], [])
    [fblock], [] -> {
      #(Last(fblock), [], [])
    }
    [], [rblock] -> {
      #(Last(rblock), [], [])
    }
    [_, ..], [] -> {
      let #(left, right) = split_list(forward)
      pop_from_double_list(left, right)
    }
    [], [_, ..] -> {
      let #(left, right) = split_list(list.reverse(reverse))
      pop_from_double_list(left, right)
    }
    [fblock, ..ftail], [rblock, ..rtail] -> #(
      Both(fblock, rblock),
      ftail,
      rtail,
    )
  }
}

pub fn two_pointers(forward, reverse, result) {
  let #(pop_result, ftail, rtail) = pop_from_double_list(forward, reverse)
  case pop_result {
    NoElements -> result
    Last(block) ->
      case block {
        Empty(_) -> result
        Data(len, id) -> [Data(len, id), ..result]
      }
    Both(fblock, rblock) ->
      case fblock, rblock {
        Data(_, _), _ -> {
          two_pointers(ftail, [rblock, ..rtail], [fblock, ..result])
        }
        _, Empty(_) -> two_pointers([fblock, ..ftail], rtail, result)
        Empty(flen), Data(rlen, rid) -> {
          case int.compare(flen, rlen) {
            order.Eq -> two_pointers(ftail, rtail, [rblock, ..result])
            order.Lt -> {
              let moved_data = Data(flen, rid)
              let remainder = Data(rlen - flen, rid)
              two_pointers(ftail, [remainder, ..rtail], [moved_data, ..result])
            }
            order.Gt -> {
              let free_space_left = Empty(flen - rlen)
              two_pointers([free_space_left, ..ftail], rtail, [rblock, ..result])
            }
          }
        }
      }
  }
}

pub fn try_insert(left, elem_to_move: Block, traversed) {
  case left {
    [] -> Error("no place found")
    [head, ..tail] -> {
      case head {
        Data(_, _) -> try_insert(tail, elem_to_move, [head, ..traversed])
        Empty(free_len) -> {
          case int.compare(free_len, elem_to_move.len) {
            order.Eq ->
              Ok(list.flatten([list.reverse(traversed), [elem_to_move], tail]))
            order.Gt -> {
              let free_space_left = Empty(free_len - elem_to_move.len)
              Ok(
                list.flatten([
                  list.reverse(traversed),
                  [elem_to_move, free_space_left],
                  tail,
                ]),
              )
            }
            order.Lt -> {
              try_insert(tail, elem_to_move, [head, ..traversed])
            }
          }
        }
      }
    }
  }
}

pub fn try_move_block(blocks, id) {
  let #(left, right) =
    list.split_while(blocks, fn(b) {
      case b {
        Empty(_) -> True
        Data(_, bid) -> bid != id
      }
    })
  let assert [elem_to_move, ..tail] = right
  case try_insert(left, elem_to_move, []) {
    Ok(new_left) -> list.flatten([new_left, [Empty(elem_to_move.len)], tail])
    Error(_) -> blocks
  }
}

pub fn get_checksum(l, i, res) {
  case l {
    [] -> res
    [Data(len, id), ..tail] ->
      case len {
        0 -> get_checksum(tail, i, res)
        _ -> get_checksum([Data(len - 1, id), ..tail], i + 1, i * id + res)
      }
    [Empty(len), ..tail] -> get_checksum(tail, i + len, res)
  }
}

pub fn main() {
  let assert Ok(text) = simplifile.read("inputs/day9/input.txt")
  let blocks =
    text
    |> string.trim_end
    |> string.split("")
    |> list.index_map(fn(c, i) {
      let assert Ok(len) = int.parse(c)
      case i % 2 == 0 {
        False -> Empty(len)
        True -> Data(len, i / 2)
      }
    })

  let #(left, right) = split_list(blocks)
  two_pointers(left, right, [])
  |> list.reverse
  |> get_checksum(0, 0)
  |> io.debug()

  let max_id =
    blocks
    |> list.filter_map(fn(x) {
      case x {
        Empty(_) -> Error(Nil)
        Data(_, id) -> Ok(id)
      }
    })
    |> list.fold(0, int.max)

  list.range(0, max_id)
  |> list.reverse
  |> list.fold(blocks, fn(blocks, i) { try_move_block(blocks, i) })
  |> get_checksum(0, 0)
  |> io.debug
}
