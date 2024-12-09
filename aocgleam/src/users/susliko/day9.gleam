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
        1 -> Free(ind / 2 + 1, el)
        _ -> File(ind / 2, el)
      }
    })
  // part1(diskmap) |> io.debug
  part2(diskmap) |> io.debug
  ""
}

fn part1(diskmap) {
  compact(diskmap, list.reverse(diskmap), [], 0, -1)
  |> list.reverse
  |> list.map(fn(el) {
    case el {
      File(id, size) -> list.repeat(id, size)
      _ -> []
    }
  })
  |> list.flatten
  |> hashsum
}

fn compact(d, revd, acc, slots, li) {
  case slots {
    0 ->
      case d {
        [Free(_, size), ..rest] -> compact(rest, revd, acc, size, li)
        [File(id, _) as file, ..rest] -> {
          let newacc = list.prepend(acc, file)
          compact(rest, revd, newacc, 0, id)
        }
        [] -> acc
      }
    slots ->
      case revd {
        [Free(_, _), ..rest] -> compact(d, rest, acc, slots, li)
        [File(id, size), ..rest] if id > li -> {
          let fits = int.min(slots, size)
          let new_acc = list.prepend(acc, File(id, fits))
          let new_revd = case fits == size {
            True -> rest
            False -> list.prepend(rest, File(id, size - fits))
          }
          case id - li {
            1 -> list.prepend(new_acc, File(id, size - fits))
            _ -> compact(d, new_revd, new_acc, slots - fits, li)
          }
        }
        _ -> acc
      }
  }
}

fn hashsum(disk) {
  disk
  |> list.index_fold(0, fn(acc, el, ind) { acc + el * ind })
}

fn part2(diskmap) {
  let #(holes, files) =
    diskmap
    |> list.partition(fn(d) {
      case d {
        Free(_, _) -> True
        File(_, _) -> False
      }
    })
  let #(filled, left) = fill_holes(holes, list.reverse(files), []) |> io.debug
  merge(filled, left, [])
  |> list.map(fn(el) {
    case el {
      File(id, size) -> list.repeat(id, size)
      Free(_, size) -> list.repeat(0, size)
    }
  })
  |> list.flatten
  |> list.reverse
}

fn merge(filled, left, acc) {
  case filled, left {
    [File(id1, _) as f1, ..r1], [File(id2, _) as f2, ..r2] ->
      case id1 < id2 {
        True -> merge(r1, left, list.prepend(acc, f1))
        False -> merge(filled, r2, list.prepend(acc, f2))
      }
    [Free(id1, _) as f1, ..r1], [File(id2, _) as f2, ..r2] ->
      case id1 > id2 {
        True -> merge(r1, left, list.prepend(acc, f1))
        False -> merge(filled, r2, list.prepend(acc, f2))
      }
    [f1], _ -> list.prepend(acc, f1)
    _, [f2] -> list.prepend(acc, f2)
    _, _ -> acc
  }
}

fn fill_holes(holes, files, left) {
  case files {
    [File(id, size) as file, ..rest] -> {
      let found =
        holes
        |> list.index_map(fn(el, i) { #(i, el) })
        |> list.find(fn(hole) {
          case hole {
            #(_, Free(ind, slots)) if id >= ind && slots >= size -> True
            _ -> False
          }
        })
      case found {
        Ok(#(i, Free(ind, slots))) -> {
          let holes2 =
            list.flatten([
              list.take(holes, i),
              [file, Free(ind, slots - size)],
              list.drop(holes, i + 1),
            ])
          fill_holes(holes2, rest, left)
        }
        _ -> fill_holes(holes, rest, list.prepend(left, file))
      }
    }
    _ -> #(holes, left)
  }
}

type Disk {
  File(id: Int, size: Int)
  Free(ind: Int, size: Int)
}
