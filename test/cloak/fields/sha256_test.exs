defmodule Cloak.Fields.SHA256Test do
  use ExUnit.Case

  alias Cloak.Fields.SHA256, as: Field

  describe ".cast/1" do
    test "leaves nil unchanged" do
      assert {:ok, nil} = Field.cast(nil)
    end

    test "leaves binary values unchanged" do
      assert {:ok, "value"} = Field.cast("value")
    end

    test "converts other values to binary" do
      assert {:ok, "123"} = Field.cast(123)
    end
  end

  describe ".dump/1" do
    test "hashes the value with sha256" do
      assert {:ok, hash} = Field.dump("value")
      assert hash == :crypto.hash(:sha256, "value")
    end
  end

  describe ".load/1" do
    test "leaves the value unchanged" do
      assert {:ok, "value"} = Field.load("value")
    end
  end
end
