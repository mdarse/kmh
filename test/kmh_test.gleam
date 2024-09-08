import gleam/dynamic
import gleeunit
import gleeunit/should
import kmh

pub fn main() {
  gleeunit.main()
}

pub fn codec_test() {
  let assert Ok(hasher) =
    kmh.new(
      prime: 1_580_030_173,
      mod_inverse: 59_260_789,
      random: 1_163_945_558,
    )
    |> kmh.validate

  hasher
  |> kmh.encode(15)
  |> should.equal(1_103_647_397)

  hasher
  |> kmh.decode(1_103_647_397)
  |> should.equal(15)
}

pub fn max_size_test() {
  let hasher =
    kmh.new(
      prime: 1_580_030_173,
      mod_inverse: 59_260_789,
      random: 1_163_945_558,
    )

  // Default max size is 31 bits, so max_value is 2^31 - 1
  hasher
  |> kmh.max_value
  |> should.equal(2_147_483_647)

  hasher
  |> kmh.max_size(10)
  |> kmh.max_value
  |> should.equal(1023)
}

pub fn validate_test() {
  let hasher =
    kmh.new(
      prime: 1_580_030_173,
      mod_inverse: 59_260_789,
      random: 1_163_945_558,
    )
  hasher
  |> kmh.validate
  |> should.be_ok
  // Dynamic is used to compare despite the phantom type
  |> dynamic.from
  |> should.equal(dynamic.from(hasher))

  kmh.new(
    // 2^31 (31 bits maximum value + 1)
    prime: 2_147_483_648,
    mod_inverse: 59_260_789,
    random: 1_163_945_558,
  )
  |> kmh.validate
  |> should.be_error
  |> should.equal(kmh.TooLargePrime)

  kmh.new(
    prime: 1_580_030_173,
    mod_inverse: 59_260_789,
    // 2^31 (31 bits maximum value + 1)
    random: 2_147_483_648,
  )
  |> kmh.validate
  |> should.equal(Error(kmh.TooLargeRandom))

  kmh.new(prime: 1, mod_inverse: 59_260_789, random: 1_163_945_558)
  |> kmh.validate
  |> should.equal(Error(kmh.NotAPrime))

  kmh.new(prime: 1_580_030_173, mod_inverse: 42, random: 1_163_945_558)
  |> kmh.validate
  |> should.equal(Error(kmh.InvalidModularInverse))
}
