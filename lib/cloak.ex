defmodule Cloak do
  @moduledoc """
  Cloak makes it easy to encrypt and decrypt database fields using
  [Ecto](http://hexdocs.pm/ecto). It consists of four components:

  - `Cloak.Cipher` - Ciphers encrypt and decrypt data using a particular
    encryption algorithm.

  - `Cloak.Vault` - Vaults configure and use ciphers. Applications can
    have multiple vaults.

  - `Cloak.Encrypted.*` - custom `Ecto.Type` modules that make it easy to use
    your vault to encrypt/decrypt fields.

  - `Mix.Tasks.Cloak.Migrate` - a task that will great simplify the process
    when you need to rotate your keys.
  """
end
