defmodule Cloak.Tags.EncoderTest do
  import Cloak.Tags.Encoder
  use ExUnit.Case, async: true

  doctest Cloak.Tags.Encoder

  describe "Cloak.Tags.Encoder/1" do
    test "when byte_size(tag) < 128 it returns a bitstring with the length as second byte" do
      assert encode(<<25, 13, 33, 41>>) == <<1, 4, 25, 13, 33, 41>>
    end

    test "when byte_size(tag) >= 128 it returns a bitstring with the length of value as multiple bytes" do
      tag = 1..4934 |> Enum.to_list() |> Enum.map(fn num -> <<num>> end) |> Enum.join()
      assert encode(tag) == <<1, 130, 19, 70>> <> tag
    end
  end
end
