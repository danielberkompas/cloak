defmodule Cloak.Fields.HMACTest do
  use ExUnit.Case

  defmodule HMAC do
    use Cloak.Fields.HMAC, otp_app: :cloak

    @impl true
    def init(_config) do
      {:ok,
       [
         algorithm: :sha512,
         secret: "secret"
       ]}
    end
  end

  @invalid_types [%{}, [], 123, 123.22]

  describe ".type/0" do
    test "returns :binary" do
      assert :binary == HMAC.type()
    end
  end

  describe ".cast/1" do
    test "returns nils unchanged" do
      assert {:ok, nil} = HMAC.cast(nil)
    end

    test "returns binaries unchanged" do
      assert {:ok, "binary"} = HMAC.cast("binary")
      assert {:ok, <<1>>} = HMAC.cast(<<1>>)
    end

    test "returns :error for all other types" do
      for type <- @invalid_types do
        assert :error = HMAC.cast(type)
      end
    end
  end

  describe ".dump/1" do
    test "returns nils unchanged" do
      assert {:ok, nil} = HMAC.dump(nil)
    end

    test "hashes binaries" do
      assert {:ok, hash} = HMAC.dump("plaintext")
      assert hash == :crypto.hmac(:sha512, "secret", "plaintext")
    end

    test "returns :error for all other types" do
      for type <- @invalid_types do
        assert :error = HMAC.dump(type)
      end
    end
  end

  describe ".load/1" do
    test "returns value unchanged" do
      assert {:ok, "value"} = HMAC.load("value")
    end
  end
end
