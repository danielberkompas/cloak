defmodule Cloak.EncryptedTimeFieldTest do
  use ExUnit.Case, async: true
  alias Cloak.EncryptedTimeField, as: Field

  setup_all do
    atom_map = %{hour: 12, minute: 0, second: 0}
    string_map = %{"hour" => 12, "minute" => 0, "second" => 0}

    {:ok, atom_map: atom_map, string_map: string_map}
  end

  test ".type is :binary" do
    assert Field.type() == :binary
  end

  test ".cast rejects invalid input" do
    assert :error == Field.cast("invalid input")
  end

  test ".cast converts maps and strings to naive datetimes", state do
    assert {:ok, ~T[12:00:00]} = Field.cast("12:00:00")
    assert {:ok, ~T[12:00:00]} = Field.cast(~T[12:00:00])
    assert {:ok, ~T[12:00:00]} = Field.cast(state[:atom_map])
    assert {:ok, ~T[12:00:00]} = Field.cast(state[:string_map])
  end

  test ".dump encrypts the value" do
    {:ok, ciphertext} = Field.dump(~T[12:00:00])
    assert ciphertext != ~T[12:00:00]
    assert ciphertext != "12:00:00"
  end

  test ".load decrypts an encrypted value" do
    {:ok, ciphertext} = Field.dump(~T[12:00:00])
    assert {:ok, ~T[12:00:00]} = Field.load(ciphertext)
  end
end
