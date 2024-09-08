with import <nixpkgs> {};
  mkShell {
    buildInputs = [
      # Workaround build issue with rebar3 on erlang:fs module
      darwin.apple_sdk.frameworks.CoreServices
    ];
    packages = [
      gleam
      erlang_27
      elixir
    ];
  }
