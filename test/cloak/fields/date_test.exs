defmodule Cloak.Fields.DateTest do
  use ExUnit.Case, async: true

  defmodule Field do
    use Cloak.Fields.Date, vault: Cloak.TestVault
  end

  test ".type is :binary" do
    assert Field.type() == :binary
  end

  test ".cast rejects invalid input" do
    assert :error == Field.cast("invalid input")
  end

  test ".cast converts maps and strings to dates" do
    assert {:ok, ~D[2017-01-05]} = Field.cast("2017-01-05")
    assert {:ok, ~D[2017-01-05]} = Field.cast(%{year: "2017", month: "1", day: "5"})
    assert {:ok, ~D[2017-01-05]} = Field.cast(%{"year" => "2017", "month" => "1", "day" => "5"})
    assert {:ok, ~D[2017-01-05]} = Field.cast(~D[2017-01-05])
  end

  test ".dump encrypts the value" do
    {:ok, ciphertext} = Field.dump(~D[2017-01-05])
    assert ciphertext != ~D[2017-01-05]
    assert ciphertext != "2017-01-05"
  end

  test ".load decrypts an encrypted value" do
    {:ok, ciphertext} = Field.dump(~D[2017-01-05])
    assert {:ok, ~D[2017-01-05]} = Field.load(ciphertext)
  end
end
