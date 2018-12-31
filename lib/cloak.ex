defmodule Cloak do
  @moduledoc """
  Cloak consists of two behaviours:

  - `Cloak.Cipher` - Ciphers encrypt and decrypt data using a particular
    encryption algorithm and key.

  - `Cloak.Vault` - Vaults configure and use ciphers. Applications can
    have multiple vaults.
  """
end
