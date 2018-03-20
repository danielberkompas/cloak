defmodule Cloak.EncryptedIntegerFieldTest do
  use ExUnit.Case

  defmodule Field do
    use Cloak.EncryptedIntegerField, vault: Cloak.TestVault
  end

  test ".type is :binary" do
    assert Field.type() == :binary
  end

  test ".cast rejects invalid input" do
    assert :error = Field.cast("21.5")
    assert :error = Field.cast(21.5)
    assert :error = Field.cast("blahblahblah")
  end

  test ".cast accepts valid input" do
    assert {:ok, 21} = Field.cast(21)
    assert {:ok, 21} = Field.cast("21")
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
