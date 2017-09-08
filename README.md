Cloak
======

[![Hex Version](http://img.shields.io/hexpm/v/cloak.svg)](https://hex.pm/packages/cloak)
[![Build Status](https://travis-ci.org/danielberkompas/cloak.svg?branch=master)](https://travis-ci.org/danielberkompas/cloak)
[![Deps Status](https://beta.hexfaktor.org/badge/all/github/danielberkompas/cloak.svg)](https://beta.hexfaktor.org/github/danielberkompas/cloak)
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
defmodule MyApp.Repo.Migrations.AddSecretKeyToModel do
  use Ecto.Migration

  def change do
    alter table(:models) do
      add :secret_key, :binary
      add :encryption_version, :binary
    end

    create index(:models, [:encryption_version])
  end
end

# in your model
defmodule MyApp.Model do
  use Ecto.Schema

  schema "models" do
    field :secret_key, Cloak.EncryptedBinaryField
    field :encryption_version, :binary
  end

  def changeset(model, params \\ :empty) do
    model
    |> cast(params, ~w(secret_key), ~w(encryption_version))
    |> put_change(:encryption_version, Cloak.version)
  end
end

# Query
MyApp.Repo.one(MyApp.Model)
# => %MyApp.Model{secret_key: "Decrypted value", encryption_version: <<"AES", 1>>}
```

## Installation

Add `cloak` to your hex dependencies:

```elixir
defp deps do
  [{:cloak, "~> 0.3.3"}]
end
```

## Documentation

See [the hex documentation](http://hexdocs.pm/cloak).

## License

MIT.
