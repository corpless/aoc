import gleam/io
import simplifile as sf

pub fn main() {
  let data = sf.read("../../inputs/day1/sample.txt")
  io.debug(data)
}
