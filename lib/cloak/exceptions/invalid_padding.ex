defmodule Cloak.InvalidPadding do
  @moduledoc """
  Indicates that a value was decrypted with the `:padding` option, but the
  decrypted plaintext was not padded.
  """
  defexception message: "could not remove padding, because the plaintext was not padded"
end
