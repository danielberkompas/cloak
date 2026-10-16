defmodule Cloak.VaultUpgradeTest do
  use ExUnit.Case

  defmodule DefaultVault do
    use Cloak.Vault, otp_app: :cloak
  end

  defmodule RuntimeVault do
    use Cloak.Vault, otp_app: :cloak

    @impl GenServer
    def init(config) do
      {:ok, Keyword.put(config, :ciphers, Application.fetch_env!(:cloak, __MODULE__))}
    end
  end

  defmodule TimeoutVault do
    use Cloak.Vault, otp_app: :cloak

    @impl GenServer
    def init(config) do
      {:ok, config, :infinity}
    end
  end

  defp cipher(tag) do
    {Cloak.Ciphers.AES.GCM, tag: tag, key: :crypto.strong_rand_bytes(32), iv_length: 12}
  end

  defp upgrade(vault) do
    :ok = :sys.suspend(vault)
    :ok = :sys.change_code(vault, vault, :old, [])
    :ok = :sys.resume(vault)
  end

  test "default init configuration remains usable after a hot upgrade" do
    start_supervised!({DefaultVault, ciphers: [default: cipher("upgrade-default")]})
    ciphertext = DefaultVault.encrypt!("before upgrade")

    upgrade(DefaultVault)

    assert {:ok, "before upgrade"} = DefaultVault.decrypt(ciphertext)
    assert {:ok, ciphertext} = DefaultVault.encrypt("after upgrade")
    assert {:ok, "after upgrade"} = DefaultVault.decrypt(ciphertext)
    assert is_list(:sys.get_state(DefaultVault))
  end

  test "hot upgrade refreshes runtime configuration and retains old-key decryption" do
    old = cipher("upgrade-old")
    new = cipher("upgrade-new")
    Application.put_env(:cloak, RuntimeVault, old: old)
    on_exit(fn -> Application.delete_env(:cloak, RuntimeVault) end)
    start_supervised!(RuntimeVault)
    ciphertext = RuntimeVault.encrypt!("before rotation")
    Application.put_env(:cloak, RuntimeVault, new: new, old: old)

    upgrade(RuntimeVault)

    assert {:ok, "before rotation"} = RuntimeVault.decrypt(ciphertext)
    new_ciphertext = RuntimeVault.encrypt!("after rotation")
    assert Cloak.Ciphers.AES.GCM.can_decrypt?(new_ciphertext, elem(new, 1))
    assert {:ok, "after rotation"} = RuntimeVault.decrypt(new_ciphertext)
  end

  test "init callbacks with a timeout also preserve configuration after a hot upgrade" do
    start_supervised!({TimeoutVault, ciphers: [default: cipher("upgrade-timeout")]})
    ciphertext = TimeoutVault.encrypt!("before upgrade")

    upgrade(TimeoutVault)

    assert {:ok, "before upgrade"} = TimeoutVault.decrypt(ciphertext)

    assert "after upgrade" ==
             "after upgrade" |> TimeoutVault.encrypt!() |> TimeoutVault.decrypt!()
  end
end
