defmodule Cloak.VaultTest do
  use ExUnit.Case

  alias Cloak.TestVault

  describe ".init/1" do
    test "returns the given config" do
      assert {:ok, []} == TestVault.init([])
    end
  end

  describe ".encrypt/1" do
    test "encrypts ciphertext" do
      assert {:ok, ciphertext} = TestVault.encrypt("plaintext")
      assert ciphertext != "plaintext"
    end
  end

  describe ".encrypt!/1" do
    test "encrypts ciphertext" do
      ciphertext = TestVault.encrypt!("plaintext")
      assert is_binary(ciphertext)
      assert ciphertext != "plaintext"
    end
  end

  describe ".encrypt/2" do
    test "encrypts ciphertext with the cipher associated with label" do
      assert {:ok, ciphertext} = TestVault.encrypt("plaintext", :secondary)
      assert ciphertext != "plaintext"
    end

    test "returns error if no cipher associated with label" do
      assert {:error, %Cloak.MissingCipher{}} = TestVault.encrypt("plaintext", :nonexistent)
    end
  end

  describe ".encrypt!/2" do
    test "encrypts ciphertext with cipher associated with label" do
      ciphertext = TestVault.encrypt!("plaintext", :secondary)
      assert is_binary(ciphertext)
      assert ciphertext != "plaintext"
    end

    test "raises error if no cipher associated with label" do
      assert_raise Cloak.MissingCipher, fn ->
        TestVault.encrypt!("plaintext", :nonexistent)
      end
    end
  end

  describe ".decrypt/1" do
    test "decrypts ciphertext" do
      {:ok, ciphertext1} = TestVault.encrypt("plaintext")
      {:ok, ciphertext2} = TestVault.encrypt("plaintext", :secondary)

      assert {:ok, "plaintext"} = TestVault.decrypt(ciphertext1)
      assert {:ok, "plaintext"} = TestVault.decrypt(ciphertext2)
    end

    test "returns error if no module found to decrypt" do
      assert {:error, %Cloak.MissingCipher{}} = TestVault.decrypt(<<123, 123>>)
    end
  end

  describe ".decrypt!" do
    test "decrypts ciphertext" do
      ciphertext1 = TestVault.encrypt!("plaintext")
      ciphertext2 = TestVault.encrypt!("plaintext", :secondary)

      assert "plaintext" == TestVault.decrypt!(ciphertext1)
      assert "plaintext" == TestVault.decrypt!(ciphertext2)
    end

    test "raises error if no module found to decrypt" do
      assert_raise Cloak.MissingCipher, fn ->
        TestVault.decrypt!(<<123, 123>>)
      end
    end
  end

  describe ".version/0" do
    test "returns :tag of default cipher" do
      {_module, opts} = Application.get_env(:cloak, Cloak.TestVault)[:ciphers][:default]
      assert TestVault.version() == opts[:tag]
    end
  end

  describe ".version/1" do
    test "returns :tag of given cipher with label" do
      {_module, opts} = Application.get_env(:cloak, Cloak.TestVault)[:ciphers][:secondary]
      assert TestVault.version(:secondary) == opts[:tag]
    end
  end

  describe ".json_library/1" do
    test "returns Poison by default" do
      assert TestVault.json_library() == Poison
    end

    test "can be configured" do
      existing = Application.get_env(:cloak, Cloak.TestVault)
      Application.put_env(:cloak, Cloak.TestVault, Keyword.merge(existing, json_library: Jason))

      assert TestVault.json_library() == Jason

      Application.put_env(:cloak, Cloak.TestVault, existing)
    end
  end
end
