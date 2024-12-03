import gleam/int
import gleam/io
import gleam/list
import gleam/result
import users/valentiay/utils

pub fn are_levels_safe(x, y, factor) {
  let diff = x - y
  let abs_diff = int.absolute_value(diff)
  let is_monotonic = diff * factor >= 0
  let is_diff_ok = 0 < abs_diff && abs_diff <= 3
  is_monotonic && is_diff_ok
}

pub fn is_report_safe(report: List(Int)) {
  let result =
    report
    |> list.window_by_2
    |> list.fold_until(0, fn(acc, pair) {
      case are_levels_safe(pair.0, pair.1, acc) {
        True -> list.Continue(pair.0 - pair.1)
        False -> list.Stop(0)
      }
    })
  result != 0
}

pub fn is_report_almost_safe(report: List(Int)) {
  list.range(0, list.length(report) + 1)
  |> list.any(fn(i) {
    report
    |> list.take(i)
    |> list.append(list.drop(report, i + 1))
    |> is_report_safe
  })
}

pub fn main() {
  use ints <- result.try(utils.read_ints("inputs/day2/input.txt"))
  //use ints <- result.try(Ok([[8, 6, 4, 4, 1]]))
  let safe_report_count = ints |> list.count(is_report_safe)
  io.debug(safe_report_count)
  let almost_safe_report_count = ints |> list.count(is_report_almost_safe)
  io.debug(almost_safe_report_count)
  Ok(0)
}
