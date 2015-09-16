defmodule Cloak.EncryptedIntegerFieldTest do
  use ExUnit.Case
  alias Cloak.EncryptedIntegerField, as: Field

  test ".type is :binary" do
    assert Field.type == :binary
  end

  test ".dump encrypts the integer" do
    {:ok, ciphertext} = Field.dump(100)
    assert ciphertext != 100
    assert ciphertext != "100"
  end

  test ".load decrypts the integer" do
    {:ok, ciphertext} = Field.dump(100)
    assert {:ok, 100} = Field.load(ciphertext)
  end
end
