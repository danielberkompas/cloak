defmodule Cloak.Fields.BinaryTest do
  use ExUnit.Case

  defmodule Field do
    use Cloak.Fields.Binary, vault: Cloak.TestVault
  end

  test ".type is :binary" do
    assert Field.type() == :binary
  end

  test ".dump encrypts the value" do
    {:ok, ciphertext} = Field.dump("value")
    assert ciphertext != "value"
  end

  test ".load decrypts the ciphertext" do
    {:ok, ciphertext} = Field.dump("value")
    assert {:ok, "value"} = Field.load(ciphertext)
  end
end
