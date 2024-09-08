# Knuth’s Multiplicative Hash

[![Package Version](https://img.shields.io/hexpm/v/kmh)](https://hex.pm/packages/kmh)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/kmh/)

```sh
gleam add kmh@1
```
```gleam
import kmh

pub fn main() {
  // Create a new hasher with a prime, modular inverse and random number
  let hasher = kmh.new(
    prime: 1_580_030_173,
    mod_inverse: 59_260_789,
    random: 1_163_945_558,
  )
  // Ensure hasher parameters are valid. This is optional, but recommended.
  let assert Ok(hasher) = kmh.validate(hasher)

  // Encode a value. For example, 15 can be a sequential internal ID that we
  // don’t want to expose.
  let public_id = kmh.encode(hasher, 15)
  // -> 1103647397

  // Decode back to the original value.
  let internal_id = kmh.decode(hasher, 1_103_647_397)
  // -> 15
}
```

> **Important note:**
> Do not reuse the hasher parameters hereabove in production. This will defeat
> the purpose of using this library.

Further documentation can be found at <https://hexdocs.pm/kmh>.

## Targets

Erlang only for now. But contributions are welcome!

## Development

```sh
gleam run   # Run the project
gleam test  # Run the tests
```
