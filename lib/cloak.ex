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

  ## Guides
  In addition to the API reference and module documentation, Cloak provides
  the following guides:

  ### How To

  - [Install Cloak](install.html)
  - [Encrypt Existing Data](encrypt_existing_data.html)
  - [Rotate Keys](rotate_keys.html)

  ### Upgrading

  - [From **0.6.x** to **0.7.x**](0.6.x_to_0.7.x.html)

  """
end
