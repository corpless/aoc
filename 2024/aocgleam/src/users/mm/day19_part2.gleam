import gleam/dict
import gleam/int
import gleam/io
import gleam/list.{Continue, Stop}
import gleam/result
import gleam/string
import simplifile

fn get_count_at_pos(str, patterns, old_dict, i) {
  let str = string.slice(str, 0, i)
  patterns
  |> list.map(fn(pattern) {
    case string.ends_with(str, pattern) {
      True ->
        dict.get(old_dict, string.length(str) - string.length(pattern))
        |> result.unwrap(0)
      False -> 0
    }
  })
  |> list.fold(0, int.add)
}

fn get_count(str, patterns) {
  list.range(1, string.length(str))
  |> list.fold(dict.from_list([#(0, 1)]), fn(old_dict, i) {
    dict.insert(old_dict, i, get_count_at_pos(str, patterns, old_dict, i))
  })
  |> dict.get(string.length(str))
  |> result.lazy_unwrap(fn() { 0 })
}

pub fn main() {
  let assert Ok(text) = simplifile.read("inputs/day19/input.txt")
  let assert [patterns, lines] = string.split(text, "\n\n")
  let patterns = string.split(patterns, ", ")
  let lines = string.split(lines, "\n")

  lines
  |> list.map(fn(str) { get_count(str, patterns) })
  |> list.fold(0, int.add)
  |> io.debug
}
