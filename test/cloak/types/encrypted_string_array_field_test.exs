defmodule Cloak.EncryptedStringArrayFieldTest do
  use ExUnit.Case
  alias Cloak.EncryptedStringArrayField, as: Field

  @list ["A", "list", "of", "strings"]

  test ".type is :binary" do
    assert Field.type() == :binary
  end

  test ".cast rejects invalid types" do
    assert :error = Field.cast("binary")
    assert :error = Field.cast(123)
    assert :error = Field.cast(123.0)
    assert :error = Field.cast(hello: :world)
    assert :error = Field.cast(%{hello: :world})
  end

  test ".cast accepts lists" do
    assert {:ok, ["hello", "world"]} = Field.cast(["hello", "world"])
  end

  test ".before_encrypt converts the list to a JSON string" do
    assert "[\"A\",\"list\",\"of\",\"strings\"]" = Field.before_encrypt(@list)
  end

  test ".before_encrypt handles list elements that are atoms" do
    assert "[\"A\",\"mixed\",\"list\"]" = Field.before_encrypt(["A", :mixed, "list"])
  end

  test ".dump encrypts the list" do
    {:ok, ciphertext} = Field.dump(@list)
    assert is_binary(ciphertext)
    assert ciphertext != @list
  end

  test ".load decrypts the list" do
    {:ok, ciphertext} = Field.dump(@list)
    assert {:ok, @list} = Field.load(ciphertext)
  end
end
