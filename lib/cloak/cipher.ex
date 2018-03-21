defmodule Cloak.Cipher do
  @moduledoc """
  A behaviour for encryption/decryption modules. Use it to write your own custom
  Cloak-compatible cipher modules.
  """

  @type plaintext :: binary
  @type ciphertext :: binary
  @type opts :: Keyword.t()

  @doc """
  Encrypt a value, using the given opts.

  Your implementation **must** include any information it will need for
  decryption in the generated ciphertext.
  """
  @callback encrypt(plaintext, opts) :: {:ok, binary} | :error

  @doc """
  Decrypt a value, using the given opts.
  """
  @callback decrypt(ciphertext, opts) :: {:ok, binary} | :error

  @doc """
  Determines if a given ciphertext can be decrypted by this cipher.
  """
  @callback can_decrypt?(ciphertext, opts) :: boolean
end
