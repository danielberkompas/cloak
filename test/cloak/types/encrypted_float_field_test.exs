defmodule Cloak.EncryptedFloatFieldTest do
  use ExUnit.Case
  alias Cloak.EncryptedFloatField, as: Field

  test ".type is :binary" do
    assert Field.type == :binary
  end

  test ".cast rejects invalid input" do
    assert :error == Field.cast("blahblah")
  end

  test ".cast converts integers and strings to floats" do
    assert {:ok, 21.0} = Field.cast(21.0)
    assert {:ok, 21.0} = Field.cast(21)
    assert {:ok, 21.0} = Field.cast("21")
    assert {:ok, 21.0} = Field.cast("21.0")
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
