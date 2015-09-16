defmodule Cloak.EncryptedFloatFieldTest do
  use ExUnit.Case
  alias Cloak.EncryptedFloatField, as: Field

  test ".type is :binary" do
    assert Field.type == :binary
  end

  test ".dump encrypts the value" do
    {:ok, ciphertext} = Field.dump(1.0)
    assert ciphertext != 1.0
    assert ciphertext != "1.0"
  end

  test ".load decrypts an encrypted value" do
    {:ok, ciphertext} = Field.dump(1.0)
    assert {:ok, 1.0} = Field.load(ciphertext)
  end
end
