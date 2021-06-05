defmodule Cloak.Crypto.Interface do
  @moduledoc false

  @type cipher :: atom
  @type key :: iodata
  @type iv :: iodata
  @type aad :: iodata
  @type plaintext :: iodata
  @type ciphertext :: iodata
  @type ciphertag :: iodata

  @doc """
  Alias for `:crypto.strong_rand_bytes/1`.
  """
  @callback strong_rand_bytes(non_neg_integer()) :: binary()

  @doc """
  Alias for `:crypto.crypto_one_time/5` with `opts[:encrypt]` set to `true`.
  """
  @callback encrypt_one_time(cipher, key, iv, plaintext) :: binary()

  @doc """
  Alias for `:crypto.crypto_one_time/5` with `opts[:encrypt]` set to `false`.
  """
  @callback decrypt_one_time(cipher, key, iv, ciphertext) :: binary()

  @doc """
  Alias for `:crypto.crypto_one_time_aead/7` with `encFlag` set to `true`.
  """
  @callback encrypt_one_time_aead(cipher, key, iv, aad, plaintext) :: {binary(), binary()}

  @doc """
  Alias for `:crypto.crypto_one_time_aead/7` with `encFlag` set to `false`.
  """
  @callback decrypt_one_time_aead(cipher, key, iv, aad, ciphertext, ciphertag) ::
              binary()

  @doc """
  Converts a cipher name to a supported cipher name, depending on the crypto library.
  """
  @callback map_cipher(atom()) :: cipher
end
