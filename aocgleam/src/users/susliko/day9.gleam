import gleam/int
import gleam/io
import gleam/list
import gleam/result
import users/susliko/utils

pub fn main() {
  let assert Ok([encoded]) = utils.read_chars("inputs/day9/sample.txt")
  let diskmap =
    encoded
    |> list.map(int.parse)
    |> result.values
    |> list.index_map(fn(el, ind) {
      case ind % 2 {
        1 -> Free(el)
        _ -> File(ind / 2, el)
      }
    })
    |> io.debug
  part1(diskmap) |> io.debug
}

fn part1(diskmap) {
  dense(diskmap, list.reverse(diskmap), [], 0, -1)
}

fn dense(
  d: List(Disk),
  revd: List(Disk),
  acc: List(Int),
  slots: Int,
  li: Int,
) -> List(Int) {
  case slots {
    0 ->
      case d {
        [Free(size), ..rest] -> dense(rest, revd, acc, size, li)
        [File(id, size), ..rest] -> {
          let newacc = list.append(acc, list.repeat(id, size))
          dense(rest, revd, newacc, 0, li + 1)
        }
        [] -> acc
      }
    slots ->
      case revd {
        [Free(_), ..rest] -> dense(d, rest, acc, slots, li)
        [File(id, size), ..rest] if id > li -> {
          let fits = int.min(slots, size)
          let new_acc = list.append(acc, list.repeat(id, fits))
          let new_revd = case fits == size {
            True -> rest
            False -> list.prepend(rest, File(id, size - fits))
          }
          dense(d, new_revd, new_acc, slots - fits, li)
        }
        _ -> acc
      }
  }
}

// TODO
// 12345
// 0..111....22222
// 022111222......
// hashsum

type Disk {
  File(id: Int, size: Int)
  Free(size: Int)
}
