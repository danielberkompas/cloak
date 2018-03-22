defmodule Cloak.Fields.BinaryTest do
  use ExUnit.Case

  defmodule Field do
    use Cloak.Fields.Binary, vault: Cloak.TestVault
  end

  @invalid_types [%{}, 123, 123.33, []]

  describe ".type/0" do
    test "returns :binary" do
      assert Field.type() == :binary
    end
  end

  describe ".cast/1" do
    test "leaves nil unchanged" do
      assert {:ok, nil} == Field.cast(nil)
    end

    test "leaves binaries unchanged" do
      assert {:ok, "binary"} = Field.cast("binary")
    end

    test "returns :error on other types" do
      for invalid <- @invalid_types do
        assert :error == Field.cast(invalid)
      end
    end
  end

  describe "dump/1" do
    test "leaves nil unchanged" do
      assert {:ok, nil} == Field.dump(nil)
    end

    test "encrypts binaries" do
      {:ok, ciphertext} = Field.dump("value")
      assert ciphertext != "value"
    end

    test "returns :error on other types" do
      for invalid <- @invalid_types do
        assert :error == Field.dump(invalid)
      end
    end
  end

  describe ".load/1" do
    test "decrypts the ciphertext" do
      {:ok, ciphertext} = Field.dump("value")
      assert {:ok, "value"} = Field.load(ciphertext)
    end
  end
end
