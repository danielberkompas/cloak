Cloak
======

[![Hex Version](http://img.shields.io/hexpm/v/cloak.svg)](https://hex.pm/packages/cloak)
[![Build Status](https://travis-ci.org/danielberkompas/cloak.svg?branch=master)](https://travis-ci.org/danielberkompas/cloak)
[![Inline docs](http://inch-ci.org/github/danielberkompas/cloak.svg?branch=master)](http://inch-ci.org/github/danielberkompas/cloak)
[![Coverage Status](https://coveralls.io/repos/github/danielberkompas/cloak/badge.svg?branch=migrate)](https://coveralls.io/github/danielberkompas/cloak?branch=migrate)

Cloak makes it easy to encrypt fields in your [Ecto](https://github.com/elixir-ecto/ecto) schemas.

## Example

Fields are encrypted with custom `Ecto.Type` modules which Cloak helps you
create.

```elixir
defmodule MyApp.EctoSchema do
  use Ecto.Schema

  schema "table_name" do
    field :encrypted_field, MyApp.Encrypted.Binary

    # ...
  end
end
```

When Ecto writes these fields to the database, it encrypts the values into
a binary blob, using a configured encryption algorithm chosen by you.

```console
iex> Repo.insert!(%MyApp.EctoSchema{encrypted_field: "plaintext"})
08:46:08.862 [debug] QUERY OK db=3.4ms
INSERT INTO "table_name" ("encrypted_field") VALUES ($1) RETURNING "id", "encrypted_field" [<<1,10, 65, 69, 83, 46, 67, 84, 82, 46, 86, 49, 69, 92, 173, 219, 203, 238, 26, 58, 236, 5, 104, 23, 12, 10, 182, 31, 221, 89, 22, 58, 34, 79, 109, 30, 70, 254, 56, 93, 102, 84>>]
```

Likewise, when Ecto reads the field out of the database, it will automatically
decrypt the value.

```elixir
iex> Repo.get(MyApp.EctoSchema, 1)
%MyApp.EctoSchema{encrypted_field: "plaintext"}
```

## Notable Features

- Transparent, easy to use encryption for database fields
- Fully compatible with umbrella projects (as of 0.7.0)
- Bring your own encryption algorithm, if you want
- Mix task for key rotation: `mix cloak.migrate`

## Security Notes

Provided encryption algorithms are based on Erlang's `:crypto` module. The 
following algorithms come with Cloak:

  - AES.GCM
  - AES.CTR

Provided encryption algorithms use random IVs for each encryption. This means
that the same value will not encrypt to the same value twice. As a result,
encrypted columns are not queryable. (However, Cloak has your back and provides
easy ways to create hashed, queryable columns)

Cloak encrypts data _at rest_ in the database. **The data in your Ecto structs
at runtime is not encrypted.**

Cloak's `Ecto.Type` modules do not support user-specific encryption keys,
due to limitations on the `Ecto.Type` behaviour. However, you can still use
Cloak's ciphers to implement these in your application logic.

## Documentation

Detailed documentation and guides are available [on Hex](https://hexdocs.pm/cloak).