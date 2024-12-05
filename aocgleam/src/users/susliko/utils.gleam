import gleam/int
import gleam/list
import gleam/result
import gleam/string
import simplifile as sf

pub type ReadError {
  IOError(sf.FileError)
  FailedToParse(List(String))
}

/// Blocks separated by a newline become top-level list elements
pub fn read_line_blocks(path: String) -> Result(List(List(String)), ReadError) {
  case sf.read(path) {
    Error(io_error) -> Error(IOError(io_error))
    Ok(data) -> {
      data
      |> string.split("\n")
      |> group_lines([], [])
      |> Ok
    }
  }
}

fn group_lines(
  lines: List(String),
  total: List(List(String)),
  cur: List(String),
) -> List(List(String)) {
  case lines {
    [] -> {
      let new_total = case cur {
        [] -> total
        cur -> list.prepend(total, cur |> list.reverse)
      }
      new_total |> list.reverse
    }
    [line, ..rest] if line == "" ->
      group_lines(rest, list.prepend(total, cur), [])
    [line, ..rest] -> group_lines(rest, total, list.prepend(cur, line))
  }
}

pub fn read_ints(path: String) -> Result(List(List(Int)), ReadError) {
  read_input(path, " ", int.parse)
}

pub fn read_chars(path: String) -> Result(List(List(String)), ReadError) {
  read_input(path, "", fn(s) { Ok(s) })
}

pub fn read_strings(path: String) -> Result(List(List(String)), ReadError) {
  read_input(path, " ", fn(s) { Ok(s) })
}

pub fn read_input(
  path: String,
  line_sep: String,
  parse: fn(String) -> Result(a, Nil),
) -> Result(List(List(a)), ReadError) {
  case sf.read(path) {
    Error(io_error) -> Error(IOError(io_error))
    Ok(data) -> {
      let #(oks, errs) =
        data
        |> string.split("\n")
        |> list.map(parse_line(_, line_sep, parse))
        |> result.partition

      case list.flatten(errs) {
        [] ->
          oks
          |> list.filter(fn(l) { !list.is_empty(l) })
          |> list.reverse
          |> Ok
        errs -> Error(FailedToParse(errs))
      }
    }
  }
}

pub fn parse_line(
  line: String,
  line_sep: String,
  parse: fn(String) -> Result(a, Nil),
) -> Result(List(a), List(String)) {
  line
  |> string.split(line_sep)
  |> list.filter(fn(el) { !string.is_empty(el) })
  |> list.map(fn(el) { result.map_error(parse(el), fn(_) { el }) })
  |> fn(l) {
    case result.partition(l) {
      #(oks, []) -> Ok(list.reverse(oks))
      #(_, errs) -> Error(errs)
    }
  }
}
