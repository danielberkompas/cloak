defmodule Cloak.PaddingTest do
  use ExUnit.Case, async: true

  alias Cloak.Padding

  doctest Padding

  describe ".pad/2" do
    test "pads to a multiple of 16 bytes by default" do
      assert Padding.pad("plaintext") == "plaintext" <> <<0x80, 0, 0, 0, 0, 0, 0>>
      assert byte_size(Padding.pad("")) == 16
      assert byte_size(Padding.pad(String.duplicate("a", 15))) == 16
    end

    test "pads to the next multiple if plaintext is as long as or longer than size" do
      assert byte_size(Padding.pad(String.duplicate("a", 16))) == 32
      assert byte_size(Padding.pad(String.duplicate("a", 17))) == 32
      assert byte_size(Padding.pad(String.duplicate("a", 30), 8)) == 32
    end

    test "counts bytes, not characters" do
      assert byte_size(Padding.pad("héllo", 8)) == 8
    end
  end

  describe ".unpad/1" do
    test "reverses pad/2 for any length" do
      for length <- 0..40, size <- [1, 8, 16, 24] do
        plaintext = :crypto.strong_rand_bytes(length)
        assert {:ok, plaintext} == plaintext |> Padding.pad(size) |> Padding.unpad()
      end
    end

    test "preserves plaintext that itself ends in padding bytes" do
      plaintext = <<"plaintext", 0x80, 0, 0>>
      assert {:ok, plaintext} == plaintext |> Padding.pad() |> Padding.unpad()
    end

    test "returns :error if the binary is not padded" do
      assert :error == Padding.unpad("plaintext")
      assert :error == Padding.unpad("")
      assert :error == Padding.unpad(<<0, 0, 0>>)
    end
  end
end
