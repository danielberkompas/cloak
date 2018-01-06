defmodule Cloak.EncryptedDateTimeFieldTest do
  use ExUnit.Case, async: true
  alias Cloak.EncryptedDateTimeField, as: Field

  setup_all do
    atom_map = %{year: 2017, month: 1, day: 5, hour: 12, minute: 0, second: 0}

    string_map = %{
      "year" => 2017,
      "month" => 1,
      "day" => 5,
      "hour" => 12,
      "minute" => 0,
      "second" => 0
    }

    dt = DateTime.from_naive!(~N[2017-01-05 12:00:00], "Etc/UTC")

    {:ok, atom_map: atom_map, string_map: string_map, dt: dt}
  end

  test ".type is :binary" do
    assert Field.type() == :binary
  end

  test ".cast rejects invalid input" do
    assert :error == Field.cast("invalid input")
  end

  test ".cast converts maps and strings to DateTimes", %{dt: dt} = state do
    assert {:ok, ^dt} = Field.cast("2017-01-05T12:00:00Z")
    assert {:ok, ^dt} = Field.cast(dt)
    assert {:ok, ^dt} = Field.cast(state[:atom_map])
    assert {:ok, ^dt} = Field.cast(state[:string_map])
  end

  test ".dump encrypts the value", %{dt: dt} do
    {:ok, ciphertext} = Field.dump(dt)
    assert ciphertext != dt
    assert ciphertext != "2017-01-0512:00:00Z"
  end

  test ".load decrypts an encrypted value", %{dt: dt} do
    {:ok, ciphertext} = Field.dump(dt)
    assert {:ok, ^dt} = Field.load(ciphertext)
  end
end
