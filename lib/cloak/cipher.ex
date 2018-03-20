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

  @doc """
  Must return a string representing the default settings of your module as it is
  currently configured.

  This will be used to generate a unique tag, which can
  then be stored on each database table row to track which encryption
  configuration it is currently encrypted with.
  """
  @callback version(opts) :: String.t()
end
