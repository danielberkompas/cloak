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

## License

MIT.
