import gleam/bool
import gleam/float
import gleam/int
import gleam/result

/// A hash function that generates obfuscated values according to Donald Knuth’s
/// multiplicative hashing algorithm.
///
/// - The hash function is bijective, meaning that it maps a number to a number
/// between 0 and the max_value.
/// - The hash function is deterministic, meaning that it always generates the
/// same output for the same input.
/// - The hash function is collision resistant, meaning that it is impossible to
/// find two different numbers that map to the same encoded value.
/// - The hash function is “one-way”, in the sense that it is infeasible to find
/// the number that maps to a given encoded value (without knowing the hash
/// parameters).
pub opaque type Hasher(validated) {
  Hasher(prime: Int, mod_inverse: Int, random: Int, max_value: Int)
}

pub type Unvalidated

pub type Valid

/// Create a new hasher.
///
/// The `prime`, `mod_inverse` and `random` values must be chosen such that the
/// following conditions are met:
///
/// - The `prime` is a prime number.
/// - The `mod_inverse` is the modular multiplicative inverse of the `prime`.
/// - The `random` value is a random number between 0 and the `max_value`.
pub fn new(
  prime prime: Int,
  mod_inverse mod_inverse: Int,
  random random: Int,
) -> Hasher(Unvalidated) {
  Hasher(prime, mod_inverse, random, max_uint_value(31))
}

/// Set the maximum size (in bits) of the values that can be generated.
/// Defaults to 31 bits.
///
/// This must be called before `validate`.
pub fn max_size(h: Hasher(Unvalidated), max_size: Int) -> Hasher(Unvalidated) {
  Hasher(..h, max_value: max_uint_value(max_size))
}

fn max_uint_value(max_size: Int) -> Int {
  max_size
  |> int.to_float
  |> int.power(2, _)
  |> result.unwrap(0.0)
  |> float.truncate
  |> int.subtract(1)
}

@internal
pub fn max_value(h: Hasher(_)) -> Int {
  h.max_value
}

/// Errors that can occur when validating a hasher.
pub type Error {
  TooLargePrime
  TooLargeRandom
  NotAPrime
  InvalidModularInverse
}

/// Validate the hasher.
///
/// Returns an error if the hasher was not created with valid parameters.
/// Returns the hasher if it was valid.
pub fn validate(h: Hasher(Unvalidated)) -> Result(Hasher(Valid), Error) {
  use <- bool.guard(h.prime > h.max_value, Error(TooLargePrime))
  use <- bool.guard(h.random > h.max_value, Error(TooLargeRandom))
  use <- bool.guard(!is_prime(h.prime), Error(NotAPrime))
  use <- bool.guard(
    int.bitwise_and(h.prime * h.mod_inverse, h.max_value) != 1,
    Error(InvalidModularInverse),
  )

  coerce(h) |> Ok
}

@external(erlang, "Elixir.Prime.MillerRabin", "test")
fn is_prime(number: Int) -> Bool

/// Encode a number.
///
/// The number must be between 0 and the max_value.
pub fn encode(h: Hasher(Valid), number: Int) -> Int {
  number
  |> int.multiply(h.prime)
  |> int.bitwise_and(h.max_value)
  |> int.bitwise_exclusive_or(h.random)
}

/// Decode a number.
///
/// The encoded value must be between 0 and the max_value.
pub fn decode(h: Hasher(Valid), number: Int) -> Int {
  number
  |> int.bitwise_exclusive_or(h.random)
  |> int.multiply(h.mod_inverse)
  |> int.bitwise_and(h.max_value)
}

/// Unsafe version of encode.
///
/// This function bypasses the validation of the hasher. Only use this if you
/// know what you are doing.
pub fn unsafe_encode(h: Hasher(_), number: Int) -> Int {
  coerce(h) |> encode(number)
}

/// Unsafe version of decode.
///
/// This function bypasses the validation of the hasher. Only use this if you
/// know what you are doing.
pub fn unsafe_decode(h: Hasher(_), number: Int) -> Int {
  coerce(h) |> decode(number)
}

fn coerce(h: Hasher(_)) -> Hasher(Valid) {
  Hasher(
    prime: h.prime,
    mod_inverse: h.mod_inverse,
    random: h.random,
    max_value: h.max_value,
  )
}
