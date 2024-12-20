import gleam/io
import gleam/list.{Continue, Stop}
import gleam/set
import gleam/string
import simplifile

fn is_possible_at_pos(str, patterns, possible_ends, i) {
  let str = string.slice(str, 0, i)
  patterns
  |> list.fold_until(False, fn(_prev_value, pattern) {
    case
      string.ends_with(str, pattern)
      && set.contains(
        possible_ends,
        string.length(str) - string.length(pattern),
      )
    {
      True -> Stop(True)
      False -> Continue(False)
    }
  })
}

fn is_possible(str, patterns) {
  list.range(1, string.length(str))
  |> list.fold(set.from_list([0]), fn(old_set, i) {
    case is_possible_at_pos(str, patterns, old_set, i) {
      True -> set.insert(old_set, i)
      False -> old_set
    }
  })
  |> set.contains(string.length(str))
}

pub fn main() {
  let assert Ok(text) = simplifile.read("inputs/day19/input.txt")
  let assert [patterns, lines] = string.split(text, "\n\n")
  let patterns = string.split(patterns, ", ")
  let lines = string.split(lines, "\n")

  lines
  |> list.count(fn(str) { is_possible(str, patterns) })
  |> io.debug
}
