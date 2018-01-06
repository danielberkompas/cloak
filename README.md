Cloak
======

[![Hex Version](http://img.shields.io/hexpm/v/cloak.svg)](https://hex.pm/packages/cloak)
[![Build Status](https://travis-ci.org/danielberkompas/cloak.svg?branch=master)](https://travis-ci.org/danielberkompas/cloak)
[![Deps Status](https://beta.hexfaktor.org/badge/all/github/danielberkompas/cloak.svg)](https://beta.hexfaktor.org/github/danielberkompas/cloak)
[![Inline docs](http://inch-ci.org/github/danielberkompas/cloak.svg?branch=master)](http://inch-ci.org/github/danielberkompas/cloak)

Cloak makes it easy to use encryption with Ecto.

[Read the docs](https://hexdocs.pm/cloak)

## Features

- Transparent encryption/decryption of fields
- Bring your own encryptor (if needed)
- Zero-downtime migration to new encryption keys
    - Multiple keys in memory at once
    - Migration task to proactively migrate rows to a new key

## Installation

Add `cloak` to your hex dependencies:

```elixir
defp deps do
  [{:cloak, "~> 0.5.0"}]
end
```

## Example

```elixir
# key generation example (random 256-bit key)
:crypto.strong_rand_bytes(32) |> Base.encode64

# in config/config.exs
config :cloak, Cloak.AES.CTR,
  tag: "AES",
  default: true,
  keys: [
    %{tag: <<1>>, key: :base64.decode("..."), default: true}
  ]

# in your migration
defmodule MyApp.Repo.Migrations.AddSecretKeyToSchema do
  use Ecto.Migration

  def change do
    alter table(:schemas) do
      add :secret_key, :binary
      add :encryption_version, :binary
    end

    create index(:schemas, [:encryption_version])
  end
end

# in your schema
defmodule MyApp.Schema do
  use Ecto.Schema

  schema "schemas" do
    field :secret_key, Cloak.EncryptedBinaryField
    field :encryption_version, :binary
  end

  def changeset(schema, params \\ %{}) do
    schema
    |> cast(params, ~w(secret_key))
    |> put_change(:encryption_version, Cloak.version)
  end
end

# Query
MyApp.Repo.one(MyApp.Schema)
# => %MyApp.Schema{secret_key: "Decrypted value", encryption_version: <<"AES", 1>>}
```

## Documentation

See [the hex documentation](http://hexdocs.pm/cloak).

## License

MIT.
