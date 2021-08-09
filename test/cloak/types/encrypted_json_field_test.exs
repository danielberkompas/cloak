defmodule Cloak.EncryptedJsonFieldTest do
  use ExUnit.Case
  alias Cloak.EncryptedJsonField, as: Field

  test ".embed_as is :dump" do
    assert Field.embed_as(:json) == :dump
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
