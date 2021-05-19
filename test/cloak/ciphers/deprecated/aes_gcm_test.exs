defmodule Cloak.Ciphers.Deprecated.AES.GCMTest do
  use ExUnit.Case

  alias Cloak.Ciphers.Deprecated.AES.GCM, as: Cipher
  alias Cloak.Tags.Encoder

  @aad "AES256GCM"
  @opts [module_tag: "AES.GCM", tag: "V1", key: :crypto.strong_rand_bytes(32)]

  describe ".encrypt/2" do
    test "raises error" do
      assert_raise RuntimeError, fn ->
        Cipher.encrypt("plaintext", @opts)
      end
    end
  end

  describe ".decrypt/2" do
    setup :create_ciphertext

    test "decrypts old ciphertext", %{ciphertext: ciphertext} do
      assert {:ok, plaintext} = Cipher.decrypt(ciphertext, @opts)
      assert plaintext == "plaintext"
    end

    test "returns error if :module_tag does not match", %{ciphertext: ciphertext} do
      assert :error == Cipher.decrypt(ciphertext, Keyword.merge(@opts, module_tag: "Other"))
    end

    test "returns error if :tag does not match", %{ciphertext: ciphertext} do
      assert :error == Cipher.decrypt(ciphertext, Keyword.merge(@opts, tag: "Other"))
    end

    test "returns error on invalid ciphertext" do
      assert :error == Cipher.decrypt(<<0, 1>>, @opts)
    end
  end

  describe ".can_decrypt?/2" do
    setup :create_ciphertext

    test "returns true if opts match", %{ciphertext: ciphertext} do
      assert Cipher.can_decrypt?(ciphertext, @opts)
    end

    test "returns false if opts don't match", %{ciphertext: ciphertext} do
      refute Cipher.can_decrypt?(ciphertext, Keyword.merge(@opts, module_tag: "Other"))
      refute Cipher.can_decrypt?(ciphertext, Keyword.merge(@opts, tag: "Other"))
    end
  end

  defp create_ciphertext(_) do
    iv = :crypto.strong_rand_bytes(16)

    {ciphertext, ciphertag} =
      Cloak.Crypto.encrypt_one_time_aead(:aes_256_gcm, @opts[:key], iv, @aad, "plaintext")

    [
      ciphertext:
        @opts[:module_tag] <> Encoder.encode(@opts[:tag]) <> iv <> ciphertag <> ciphertext
    ]
  end
end
