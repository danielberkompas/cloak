defmodule Cloak.Tags.DecoderTest do
  import Cloak.Tags.Decoder
  use ExUnit.Case, async: true

  doctest Cloak.Tags.Decoder

  describe "Cloak.Tags.Encoder/1" do
    test "it returns a key_tag and remainder as a map" do
      assert decode(<<1, 4, 25, 13, 33, 41, 1, 2>>) == %{
               key_tag: <<25, 13, 33, 41>>,
               remainder: <<1, 2>>
             }
    end

    test "it can decode tags of arbitrary length" do
      tag = 1..4934 |> Enum.to_list() |> Enum.map(fn num -> <<num>> end) |> Enum.join()

      assert decode(<<1, 130, 19, 70>> <> tag <> <<20, 30, 12>>) == %{
               key_tag: tag,
               remainder: <<20, 30, 12>>
             }
    end
  end
end
