import gleam/int
import gleam/io
import gleam/list
import gleam/option
import gleam/regexp
import gleam/result
import simplifile as sf

pub fn main() {
  let assert Ok(raw_str) = sf.read("inputs/day3/sample.txt")

  part1(raw_str) |> io.debug
  part2(raw_str) |> io.debug
}

fn part1(raw_str) {
  let assert Ok(re) = regexp.from_string("mul\\(([0-9]+),([0-9]+)\\)")
  regexp.scan(re, raw_str)
  |> list.map(fn(match) {
    case match.submatches {
      [option.Some(a), option.Some(b), ..] -> {
        use ap <- result.try(int.parse(a))
        use bp <- result.try(int.parse(b))
        Ok(ap * bp)
      }
      _ -> Error(Nil)
    }
  })
  |> result.values
  |> list.fold(0, int.add)
}

fn part2(raw_str) {
  let do = "do\\(\\)"
  let dont = "don't\\(\\)"
  let mul = "mul\\(([0-9]+),([0-9]+)\\)"
  let assert Ok(re) = regexp.from_string(do <> "|" <> dont <> "|" <> mul)

  regexp.scan(re, raw_str)
  |> io.debug
  |> list.map(fn(match) {
    case match.submatches {
      [option.Some(a), option.Some(b), ..] -> {
        use ap <- result.try(int.parse(a))
        use bp <- result.try(int.parse(b))
        Ok(ap * bp)
      }
      _ -> Error(Nil)
    }
  })
  |> result.values
  |> list.fold(0, int.add)
}
