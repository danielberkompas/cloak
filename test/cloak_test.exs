defmodule CloakTest do
  use ExUnit.Case
  import Cloak

  doctest Cloak

  describe "default cipher tests" do
    test "Cloak.encrypt/1 can encrypt a value" do
      refute encrypt("value") == "value"
    end

    test "Cloak.encrypt/1 prepends the cipher tag to the ciphertext" do
      assert <<"AES", _ciphertext::binary>> = encrypt("value")
    end

    test "Cloak.decrypt/1 can decrypt a value" do
      assert encrypt("value") |> decrypt == "value"
    end

    test "Cloak.version/0 returns the default cipher tag joined with the cipher.version" do
      assert <<"AES", 1>> = version()
    end
  end

  describe "non default cipher tests" do
    defmodule TestCipher do
      @behaviour Cloak.Cipher

      def encrypt(plaintext, key_tag \\ nil) do
        key =
          Cloak.Ciphers.Util.config(__MODULE__, key_tag) ||
            Cloak.Ciphers.Util.default_key(__MODULE__)

        key.tag <> Base.encode64(plaintext)
      end

      def decrypt(<<_key_tag::binary-1, ciphertext::binary>> = _encrypted) do
        Base.decode64!(ciphertext)
      end

      def version, do: Cloak.Ciphers.Util.default_key(__MODULE__).tag
    end

    setup do
      non_default_cipher = [
        default: false,
        tag: "TEST",
        keys: [
          %{tag: <<1>>, key: "abc123xyz456", default: true}
        ]
      ]

      Application.put_env(:cloak, TestCipher, non_default_cipher)

      on_exit(fn ->
        Application.delete_env(:cloak, TestCipher)
      end)
    end

    test "Cloak.decrypt/1 can decrypt a value encrypted by a non-default encrypter" do
      encrypted = encrypt("other_cipher_value", "TEST")
      assert decrypt(encrypted) == "other_cipher_value"
    end

    test "Cloak.version/1 returns the non default cipher tag joined with the cipher.version" do
      assert <<"TEST", 1>> = version("TEST")
    end
  end
end
