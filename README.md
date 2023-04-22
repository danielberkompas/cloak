Cloak
======

[![Hex Version](http://img.shields.io/hexpm/v/cloak.svg)](https://hex.pm/packages/cloak)
[![Hex Docs](https://img.shields.io/badge/hex-docs-lightgreen.svg)](https://hexdocs.pm/cloak/)
[![Total Download](https://img.shields.io/hexpm/dt/cloak.svg)](https://hex.pm/packages/cloak)
[![License](https://img.shields.io/hexpm/l/cloak.svg)](https://github.com/danielberkompas/cloak/blob/master/LICENSE.md)
[![Last Updated](https://img.shields.io/github/last-commit/danielberkompas/cloak.svg)](https://github.com/danielberkompas/cloak/commits/master)
[![Build Status](https://danielberkompas.semaphoreci.com/badges/cloak/branches/master.svg?style=shields)](https://danielberkompas.semaphoreci.com/projects/cloak)
[![Inline docs](http://inch-ci.org/github/danielberkompas/cloak.svg?branch=master)](http://inch-ci.org/github/danielberkompas/cloak)
[![Coverage Status](https://coveralls.io/repos/github/danielberkompas/cloak/badge.svg?branch=migrate)](https://coveralls.io/github/danielberkompas/cloak?branch=migrate)


Cloak is an Elixir encryption library that implements several best practices
and conveniences for Elixir developers:

- Random IVs
- Tagged ciphertexts
- Elixir-native configuration

## Documentation

- [Hex Documentation](https://hexdocs.pm/cloak) (Includes installation guide)
- [How to upgrade from Cloak 0.9.x to 1.0.x](https://hexdocs.pm/cloak/0-9-x_to_1-0-x.html)

## Examples

### Encrypt / Decrypt

```elixir
{:ok, ciphertext} = MyApp.Vault.encrypt("plaintext")
# => {:ok, <<1, 10, 65, 69, 83, 46, 71, 67, 77, 46, 86, 49, 45, 1, 250, 221,
# =>  189, 64, 26, 214, 26, 147, 171, 101, 181, 158, 224, 117, 10, 254, 140, 207,
# =>  215, 98, 208, 208, 174, 162, 33, 197, 179, 56, 236, 71, 81, 67, 85, 229,
# =>  ...>>}

MyApp.Vault.decrypt(ciphertext)
# => {:ok, "plaintext"}
```

### Reencrypt With New Algorithm/Key

```elixir
"plaintext"
|> MyApp.Vault.encrypt!(:aes_256)
|> MyApp.Vault.decrypt!()
|> MyApp.Vault.encrypt!(:aes_256)
|> MyApp.Vault.decrypt!()
# => "plaintext"
```

### Configuration

```elixir
config :my_app, MyApp.Vault,
  ciphers: [
    # In AES.GCM, it is important to specify 12-byte IV length for
    # interoperability with other encryption software. See this GitHub issue
    # for more details: https://github.com/danielberkompas/cloak/issues/93
    #
    # In Cloak 2.0, this will be the default iv length for AES.GCM.
    aes_gcm: {Cloak.Ciphers.AES.GCM, tag: "AES.GCM.V1", key: <<...>>, iv_length: 12},
    aes_ctr: {Cloak.Ciphers.AES.CTR, tag: "AES.CTR.V1", key: <<...>>}
  ]
```

## Features

### Random Initialization Vectors (IV)

Every strong encryption algorithm recommends unique initialization vectors.
Cloak automatically generates unique vectors using
`:crypto.strong_rand_bytes`, and includes the IV in the ciphertext.
This greatly simplifies storage and is not a security risk.

### Tagged Ciphertext

Each ciphertext contains metadata about the algorithm and key which was used
to encrypt it. This allows Cloak to automatically select the correct key and
algorithm to use for decryption for any given ciphertext.

This makes key rotation much easier, because you can easily tell whether any
given ciphertext is using the old key or the new key.

### Elixir-Native Configuration

Cloak works through `Vault` modules which you define in your app, and add
to your supervision tree.

You can have as many vaults as you wish running simultaneously in your
project. (This works well with umbrella apps, or any runtime environment
where you have multiple OTP apps using Cloak)

### Ecto Support

You can use Cloak to transparently encrypt Ecto fields, using
[`cloak_ecto`](https://hex.pm/packages/cloak_ecto).

## Security Notes

- Cloak is built on Erlang's `crypto` library, and therefore inherits its security.
- You can implement your own cipher modules to use with Cloak, which may use any other encryption algorithms of your choice.

## Copyright and License

Copyright (c) 2015 Daniel Berkompas

This work is free. You can redistribute it and/or modify it under the
terms of the MIT License. See the [LICENSE.md](./LICENSE.md) file for more details.
