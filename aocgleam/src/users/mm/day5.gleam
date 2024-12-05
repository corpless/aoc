import gleam/dict
import gleam/int
import gleam/io
import gleam/list
import gleam/set
import gleam/string
import simplifile

fn first_is_sorted(rules, first, rest) {
  case rest {
    [] -> True
    [next, ..tail] -> {
      case dict.get(rules, next) {
        Ok(required_after_next) ->
          !set.contains(required_after_next, first)
          && first_is_sorted(rules, first, tail)
        _ -> first_is_sorted(rules, first, tail)
      }
    }
  }
}

fn all_sorted(rules, l) {
  case l {
    [] -> True
    [first, ..rest] ->
      first_is_sorted(rules, first, rest) && all_sorted(rules, rest)
  }
}

fn push_first_unsorted_to_end(rules, left, right) {
  case right {
    [] -> Error("list is sorted")
    [rhead, ..rtail] -> {
      case first_is_sorted(rules, rhead, rtail) {
        False ->
          Ok(
            list.flatten([
              list.reverse(left),
              list.reverse([rhead, ..list.reverse(rtail)]),
            ]),
          )
        True -> push_first_unsorted_to_end(rules, [rhead, ..left], rtail)
      }
    }
  }
}

fn sort(rules, l) {
  case push_first_unsorted_to_end(rules, [], l) {
    Error(_) -> l
    Ok(newlist) -> sort(rules, newlist)
  }
}

fn sum_middles(updates) {
  updates
  |> list.map(fn(update) {
    let #(_left, right) = list.split(update, list.length(update) / 2)
    let assert Ok(middle) = list.first(right)
    middle
  })
  |> list.fold(0, int.add)
}

pub fn main() {
  let assert Ok(text) = simplifile.read("inputs/day5/input.txt")
  let assert [text1, text2] = string.split(text, "\n\n")
  let rules =
    text1
    |> string.split("\n")
    |> list.map(fn(line) {
      let assert [a, b] = string.split(line, "|")
      let assert Ok(a_int) = int.parse(a)
      let assert Ok(b_int) = int.parse(b)
      #(a_int, b_int)
    })
    |> list.group(fn(x) { x.0 })
    |> dict.map_values(fn(_, values) {
      set.from_list(list.map(values, fn(x) { x.1 }))
    })
  let updates =
    text2
    |> string.split("\n")
    |> list.filter(fn(line) { line != "" })
    |> list.map(fn(line) {
      line
      |> string.split(",")
      |> list.map(fn(s) {
        let assert Ok(page) = int.parse(s)
        page
      })
    })

  updates
  |> list.filter(fn(update) { all_sorted(rules, update) })
  |> sum_middles
  |> io.debug

  updates
  |> list.filter(fn(update) { !all_sorted(rules, update) })
  |> list.map(fn(u) { sort(rules, u) })
  |> sum_middles
  |> io.debug
}
