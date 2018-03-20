defmodule Cloak.Cipher.Deprecated.AES.CTRTest do
  use ExUnit.Case

  alias Cloak.Cipher.Deprecated.AES.CTR, as: Cipher

  @opts [module_tag: "AES.CTR", tag: "V1", key: :crypto.strong_rand_bytes(32)]

  describe ".encrypt/2" do
    test "raises error, preventing use" do
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

  # Replicates the old format for AES.CTR, where the module tag
  # and key tag were prepended to the iv and ciphertext.
  defp create_ciphertext(_) do
    iv = :crypto.strong_rand_bytes(16)
    state = :crypto.stream_init(:aes_ctr, @opts[:key], iv)
    {_state, ciphertext} = :crypto.stream_encrypt(state, "plaintext")
    [ciphertext: @opts[:module_tag] <> @opts[:tag] <> iv <> ciphertext]
  end
end
