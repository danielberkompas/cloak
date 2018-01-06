defmodule Cloak.Tags.Encoder do
  # An encoder that allows us to specify tags of arbitrary length.
  #
  # This scheme follows a Type, Length, Value triplet and is based on DER
  # encoding for certificates. https://en.wikipedia.org/wiki/X.690#DER_encoding
  #
  # If the value field (tag) is less than 128 bytes, the Length field only
  # requires 1 byte.
  #
  # If the Value field contains more than 127 bytes, bit 7 of the Length field
  # is one (1) and the remaining bits identify the number of bytes needed to
  # contain the length.
  #
  # Examples are shown in the following illustration.
  #
  #     +---+---+---+---+---+---+---+---+----------------+
  #     | 0 | 0 | 1 | 1 | 0 | 1 | 0 | 0 | 52 value bytes |
  #     +---+---+---+---+---+---+---+---+----------------+
  #     <===   Length Bytes == 52  ====>
  #
  #
  #     +---+---+---+---+---+---+---+---++---+---+---+---+---+---+---+---++---+---+---+---+---+---+---+---+------------------+
  #     | 1 | 0 | 0 | 0 | 0 | 0 | 1 | 0 || 0 | 0 | 0 | 1 | 0 | 0 | 1 | 1 || 0 | 1 | 0 | 0 | 0 | 1 | 1 | 0 | 4934 value bytes |
  #     +---+---+---+---+---+---+---+---++---+---+---+---+---+---+---+---++---+---+---+---+---+---+---+---+------------------+
  #     <===   Length Bytes == 2  ====>   <=====         Number of Value Bytes == 4934              =====>
  #
  # We reserve the first byte for potential use in the future, as it represents
  # the tag in the TLV triplet.

  # Exclude this module from public documentation as it should only be used
  # internally by Cloak
  @moduledoc false

  @reserved <<1>>
  @byte_length 256
  @half_byte 128

  def encode(value) when byte_size(value) >= @half_byte do
    value |> byte_size() |> to_bitstring() |> encode(value)
  end

  def encode(value) do
    @reserved <> <<byte_size(value)>> <> value
  end

  def encode(bitstring, value) do
    @reserved <> <<@half_byte + byte_size(bitstring)>> <> bitstring <> value
  end

  defp to_bitstring(decimal) do
    decimal
    |> convert()
    |> Enum.map(fn num -> <<num>> end)
    |> Enum.join()
  end

  defp convert(decimal), do: convert(decimal, [])
  defp convert(0, list), do: list

  defp convert(decimal, list) do
    convert(div(decimal, @byte_length), [rem(decimal, @byte_length) | list])
  end
end
