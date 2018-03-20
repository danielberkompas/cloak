defmodule Cloak do
  @moduledoc """
  Cloak makes it easy to encrypt and decrypt database fields using
  [Ecto](http://hexdocs.pm/ecto). It consists of four components:

  - `Cloak.Cipher` - ciphers encrypt and decrypt data using a particular
    encryption algorithm.

  - `Cloak.Vault` - vaults configure and use ciphers. Applications can
    have multiple vaults.

  - `Ecto.Type`s - custom Ecto types that make it easy to use your vault
    to encrypt/decrypt your fields.

  - `Mix.Tasks.Cloak.Migrate` - a task that will great simplify the process
    when you need to rotate your keys.
  """
end
