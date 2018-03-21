defmodule Cloak.Ciphers.AES.GCMTest do
  use ExUnit.Case

  alias Cloak.Ciphers.AES.GCM, as: Cipher

  @opts [tag: "AES.GCM.V1", key: :crypto.strong_rand_bytes(32)]

  describe ".encrypt/2" do
    test "encrypts binaries" do
      assert Cipher.encrypt("hello world", @opts) != {:ok, "hello world"}
      assert Cipher.encrypt(~S[{"hello": "world"}], @opts) != {:ok, ~S[{"hello": "world"}]}
    end

    test "returns ciphertext in the format key_tag <> iv <> ciphertag <> ciphertext" do
      assert {:ok,
              <<_type::binary-1, _length::binary-1, "AES.GCM.V1", iv::binary-16,
                ciphertag::binary-16, ciphertext::binary>>} = Cipher.encrypt("plaintext", @opts)

      assert byte_size(iv) == 16
      assert byte_size(ciphertag) == 16
      assert String.length(ciphertext) > 0
    end

    test "does not produce the same ciphertext twice" do
      assert Cipher.encrypt("hello world", @opts) != Cipher.encrypt("hello world", @opts)
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

    test "can decrypt a value", %{ciphertext: ciphertext} do
      assert Cipher.decrypt(ciphertext, @opts) == {:ok, "plaintext"}
    end

    test "returns error when decrypting with wrong key", %{ciphertext: ciphertext} do
      assert :error ==
               Cipher.decrypt(ciphertext, tag: "OtherTag", key: :crypto.strong_rand_bytes(32))
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

  describe ".version/1" do
    test "returns the current tag" do
      assert Cipher.version(@opts) == @opts[:tag]
    end
  end

  defp create_ciphertext(_) do
    {:ok, ciphertext} = Cipher.encrypt("plaintext", @opts)
    [ciphertext: ciphertext]
  end
end
