defmodule Cloak.Ciphers.AES.CTRTest do
  use ExUnit.Case

  alias Cloak.Ciphers.AES.CTR, as: Cipher

  @opts [tag: "AES.CTR.V1", key: :crypto.strong_rand_bytes(32)]

  describe ".encrypt/2" do
    test "encrypts plaintext" do
      assert {:ok, ciphertext} = Cipher.encrypt("plaintext", @opts)
      assert ciphertext != "plaintext"
    end

    test "produces ciphertext in the format tag <> iv <> ciphertext" do
      assert {:ok,
              <<_type::binary-1, _length::binary-1, "AES.CTR.V1", iv::binary-16,
                ciphertext::binary>>} = Cipher.encrypt("plaintext", @opts)

      assert byte_size(iv) == 16
      assert String.length(ciphertext) > 0
    end

    test "produces a different ciphertext each time" do
      assert {:ok, ciphertext1} = Cipher.encrypt("plaintext", @opts)
      assert {:ok, ciphertext2} = Cipher.encrypt("plaintext", @opts)
      assert ciphertext1 != ciphertext2
    end

    test "raises error if :key not passed" do
      assert_raise KeyError, fn ->
        Cipher.encrypt("plaintext", tag: @opts[:tag])
      end
    end

    test "raises error if :tag not passed" do
      assert_raise KeyError, fn ->
        Cipher.encrypt("plaintext", key: @opts[:key])
      end
    end
  end

  describe ".decrypt/2" do
    setup :create_ciphertext

    test "decrypts ciphertext", %{ciphertext: ciphertext} do
      assert {:ok, plaintext} = Cipher.decrypt(ciphertext, @opts)
      assert plaintext == "plaintext"
    end

    test "returns error if given invalid ciphertext" do
      assert :error == Cipher.decrypt(<<0, 1>>, @opts)
    end

    test "raises error if :key not passed", %{ciphertext: ciphertext} do
      assert_raise KeyError, fn ->
        Cipher.decrypt(ciphertext, tag: @opts[:tag])
      end
    end

    test "raises error if :tag not passed", %{ciphertext: ciphertext} do
      assert_raise KeyError, fn ->
        Cipher.decrypt(ciphertext, key: @opts[:key])
      end
    end
  end

  describe ".can_decrypt?/2" do
    setup :create_ciphertext

    test "returns true if tag and format matches", %{ciphertext: ciphertext} do
      assert Cipher.can_decrypt?(ciphertext, @opts)
    end

    test "returns false if tag does not match", %{ciphertext: ciphertext} do
      refute Cipher.can_decrypt?(ciphertext, tag: "OtherTag", key: @opts[:key])
    end

    test "returns false if tag matches but format does not" do
      refute Cipher.can_decrypt?(<<1, 10, "AES.CTR.V1", 0, 0>>, @opts)
    end
  end

  defp create_ciphertext(_) do
    {:ok, ciphertext} = Cipher.encrypt("plaintext", @opts)
    [ciphertext: ciphertext]
  end
end
