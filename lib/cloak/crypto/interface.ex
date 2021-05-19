defmodule Cloak.Crypto.Interface do
  @doc ~S"""
  Forward to `:crypto.strong_rand_bytes/1`
  """
  @callback strong_rand_bytes(non_neg_integer()) :: binary()
  @callback encrypt_one_time(atom(), iodata(), iodata(), iodata()) :: binary()
  @callback decrypt_one_time(atom(), iodata(), iodata(), iodata()) :: binary()
  @callback encrypt_one_time_aead(atom(), iodata(), iodata(), iodata(), iodata()) :: binary()
  @callback decrypt_one_time_aead(atom(), iodata(), iodata(), iodata(), iodata(), iodata()) ::
              binary()
end
