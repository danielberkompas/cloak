defmodule Cloak.Tags.Decoder do
  # A decoder that will let us read tags specified in the Format specified by
  # the `Cloak.Tags.Encoder`
  #
  # This scheme follows a Type, Length, Value triplet and is based on DER
  # encoding for certificates https://en.wikipedia.org/wiki/X.690#DER_encoding
  #
  # It returns a map containing the tag and the remainder of the binary
  # which we can use to decode the ciphertext.

  # Exclude this module from public documentation as it should only be used
  # internally by Cloak
  @moduledoc false

  @offset 2
  @byte_length 256
  @half_byte 128

  def decode(<<_type::size(8), len::size(8), rest::binary>> = message) do
    tag_length =
      if len >= @half_byte do
        <<value::binary-size(len - @half_byte), _::binary>> = rest
        @offset + len - @half_byte + value_bytes(:binary.bin_to_list(value))
      else
        @offset + len
      end

    case message do
      <<tlv::binary-size(tag_length), remainder::binary>> ->
        %{tag: tag(tlv), remainder: remainder}

      _other ->
        :error
    end
  end

  defp tag(<<_type::size(8), len::size(8), rest::binary>>) when len >= @half_byte do
    size = len - @half_byte
    <<_value_bytes::binary-size(size), tag::binary>> = rest

    tag
  end

  defp tag(<<_type::size(8), _len::size(8), tag::binary>>) do
    tag
  end

  defp value_bytes(list) do
    Enum.reduce(list, 0, fn value, acc -> acc * @byte_length + value end)
  end
end
