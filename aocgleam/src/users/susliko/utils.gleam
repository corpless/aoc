import gleam/int
import gleam/list
import gleam/result
import gleam/string
import simplifile as sf

pub type ReadError {
  IOError(sf.FileError)
  FailedToParse(List(String))
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

fn parse_line(
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
