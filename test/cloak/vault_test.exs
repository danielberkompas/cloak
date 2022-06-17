defmodule Cloak.VaultTest do
  use ExUnit.Case

  alias Cloak.TestVault

  defmodule RuntimeVault do
    use Cloak.Vault, otp_app: :cloak
  end

  defmodule SupervisedVault do
    use Cloak.Vault, otp_app: :cloak
  end

  describe ".start_link/1" do
    test "allows configuration" do
      key = :crypto.strong_rand_bytes(32)

      {:ok, pid} =
        RuntimeVault.start_link(
          ciphers: [
            default: {Cloak.Ciphers.AES.GCM, tag: "AES.GCM.V1", key: key}
          ],
          json_library: Jason
        )

      assert RuntimeVault.json_library() == Jason

      assert "plaintext" ==
               "plaintext"
               |> RuntimeVault.encrypt!()
               |> RuntimeVault.decrypt!()

      GenServer.stop(pid)
    end

    test "can be supervised" do
      assert {:ok, pid} = Supervisor.start_link([SupervisedVault], strategy: :one_for_one)
      assert SupervisedVault.json_library() == Jason
      GenServer.stop(pid)

      assert {:ok, pid} =
               Supervisor.start_link(
                 [
                   {SupervisedVault, json_library: Jason}
                 ],
                 strategy: :one_for_one
               )

      assert SupervisedVault.json_library() == Jason
      GenServer.stop(pid)
    end

    test "can be re-started" do
      {:ok, _} = RuntimeVault.start_link()
      {:error, {:already_started, _}} = RuntimeVault.start_link()
    end
  end

  describe ".init/1" do
    test "returns the given config" do
      assert {:ok, [], {:continue, :save_config}} == TestVault.init([])
    end
  end

  describe ".encrypt/1" do
    test "encrypts ciphertext" do
      assert {:ok, ciphertext} = TestVault.encrypt("plaintext")
      assert ciphertext != "plaintext"
    end

    test "returns error if vault is not configured correctly" do
      {:ok, pid} = RuntimeVault.start_link()

      assert {:error, %Cloak.InvalidConfig{}} = RuntimeVault.encrypt("plaintext")

      GenServer.stop(pid)
    end
  end

  describe ".encrypt!/1" do
    test "encrypts ciphertext" do
      ciphertext = TestVault.encrypt!("plaintext")
      assert is_binary(ciphertext)
      assert ciphertext != "plaintext"
    end

    test "raises error if vault is not configured correctly" do
      {:ok, pid} = RuntimeVault.start_link()

      assert_raise Cloak.InvalidConfig, fn ->
        RuntimeVault.encrypt!("plaintext")
      end

      GenServer.stop(pid)
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

  describe ".json_library/1" do
    test "returns Jason by default" do
      assert TestVault.json_library() == Jason
    end
  end
end
