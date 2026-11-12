defmodule Cloak.Padding do
  @moduledoc """
  Pads plaintext before encryption, so that the length of the ciphertext
  does not reveal the length of the plaintext.

  This matters most for fields with a small set of possible values, such as
  enums or booleans. Without padding, `"yes"` and `"no"` produce ciphertexts
  of different lengths, which tells an attacker which value is stored.

  Padding follows ISO/IEC 7816-4: a `0x80` byte is appended, followed by as
  many `0x00` bytes as needed to reach the next multiple of `size`. Padding is
  always added, even if the plaintext is already a multiple of `size`, so that
  it can be removed unambiguously.

  You normally don't call this module directly. Pass the `:padding` option to
  the encrypt and decrypt functions of your `Cloak.Vault` instead.
  """

  @default_size 16

  @doc """
  Pads `plaintext` to the next multiple of `size` bytes.

      iex> Cloak.Padding.pad("yes", 8)
      <<"yes", 0x80, 0, 0, 0, 0>>

      iex> Cloak.Padding.pad("12345678", 8)
      <<"12345678", 0x80, 0, 0, 0, 0, 0, 0, 0>>
  """
  @spec pad(binary, pos_integer) :: binary
  def pad(plaintext, size \\ @default_size)
      when is_binary(plaintext) and is_integer(size) and size > 0 do
    zeros = size - 1 - rem(byte_size(plaintext), size)
    <<plaintext::binary, 0x80, 0::size(zeros)-unit(8)>>
  end

  @doc """
  Removes the padding added by `pad/2`. Returns `:error` if `padded` does not
  end in valid padding.

      iex> Cloak.Padding.unpad(<<"yes", 0x80, 0, 0, 0, 0>>)
      {:ok, "yes"}

      iex> Cloak.Padding.unpad("yes")
      :error
  """
  @spec unpad(binary) :: {:ok, binary} | :error
  def unpad(padded) when is_binary(padded) do
    unpad(padded, byte_size(padded))
  end

  defp unpad(_padded, 0), do: :error

  defp unpad(padded, length) do
    case :binary.at(padded, length - 1) do
      0x00 -> unpad(padded, length - 1)
      0x80 -> {:ok, binary_part(padded, 0, length - 1)}
      _other -> :error
    end
  end
end
