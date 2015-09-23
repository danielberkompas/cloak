Cloak
======

[![Hex Version](http://img.shields.io/hexpm/v/cloak.svg)](https://hex.pm/packages/cloak)
[![Build Status](https://travis-ci.org/danielberkompas/cloak.svg?branch=master)](https://travis-ci.org/danielberkompas/cloak)
[![Inline docs](http://inch-ci.org/github/danielberkompas/cloak.svg?branch=master)](http://inch-ci.org/github/danielberkompas/cloak)

Cloak makes it easy to use encryption with Ecto.

## Features

- Transparent encryption/decryption of fields
- Bring your own encryptor (if needed)
- Zero-downtime migration to new encryption keys
    - Multiple keys in memory at once
    - Migration task to proactively migrate rows to a new key

## Example

```elixir
# in config/config.exs
config :cloak, Cloak.AES.CTR,
  tag: "AES",
  default: true,
  keys: [
    %{tag: <<1>>, key: :base64.decode("..."), default: true}
  ]

# in your model
defmodule MyApp.Model do
  use Ecto.Model
  use Cloak.Model, :encryption_version

  schema "models" do
    field :field_name, Cloak.EncryptedBinaryField
    field :encryption_version, :binary
  end
end

# Query
MyApp.Repo.one(MyApp.Model)
# => %MyApp.Model{field_name: "Decrypted value", encryption_version: <<"AES", 1>>}
```

## Installation

Add `cloak` to your hex dependencies:

```elixir
defp deps do
  [{:cloak, "~> 0.1.0"}]
end
```

## Documentation

See [the hex documentation](http://hexdocs.pm/cloak).

## License

MIT.
