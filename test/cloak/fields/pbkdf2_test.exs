defmodule Cloak.Fields.PBKDF2Test do
  use ExUnit.Case

  defmodule Field do
    use Cloak.Fields.PBKDF2, otp_app: :cloak

    @impl true
    def init(_config) do
      {:ok, [algorithm: :sha256, iterations: 1, secret: "secret", size: 32]}
    end
  end

  @invalid_types [%{}, [], 123, 123.22]

  describe ".type/0" do
    test "returns :binary" do
      assert :binary == Field.type()
    end
  end

  describe ".cast/1" do
    test "leaves nil unchanged" do
      assert {:ok, nil} = Field.cast(nil)
    end

    test "leaves binary values unchanged" do
      assert {:ok, "value"} = Field.cast("value")
      assert {:ok, <<1>>} = Field.cast(<<1>>)
    end

    test "returns :error for all other types" do
      for type <- @invalid_types do
        assert :error = Field.cast(type)
      end
    end
  end

  describe ".dump/1" do
    test "returns nils unchanged" do
      assert {:ok, nil} = Field.dump(nil)
    end

    test "derives a key for binaries" do
      assert {:ok, key} = Field.dump("value")
      assert 32 == byte_size(key)
    end

    test "returns :error for all other types" do
      for type <- @invalid_types do
        assert :error = Field.dump(type)
      end
    end
  end

  describe ".load/1" do
    test "returns value unchanged" do
      assert {:ok, "value"} = Field.load("value")
    end
  end
end
