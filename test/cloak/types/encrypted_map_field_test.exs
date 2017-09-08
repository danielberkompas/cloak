defmodule Cloak.EncryptedMapFieldTest do
  use ExUnit.Case
  alias Cloak.EncryptedMapField, as: Field

  @map %{"key" => "value"}

  test ".type is :binary" do
    assert Field.type == :binary
  end

  test ".before_encrypt converts the map to a JSON string" do
    assert "{\"key\":\"value\"}" = Field.before_encrypt(@map)
  end

  test ".dump encrypts the map" do
    {:ok, ciphertext} = Field.dump(@map)
    assert is_binary(ciphertext)
    assert ciphertext != @map
  end

  test ".load decrypts the map" do
    {:ok, ciphertext} = Field.dump(@map)
    assert {:ok, @map} = Field.load(ciphertext)
  end
end
