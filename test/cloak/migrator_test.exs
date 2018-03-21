defmodule Cloak.MigratorTest do
  use Cloak.DataCase

  alias Cloak.Migrator
  alias Cloak.TestUser, as: User
  alias Cloak.TestVault, as: Vault

  @email "test@email.com"

  defp create_user(_) do
    [user: Factory.create_user(@email)]
  end

  defp migrate(_) do
    Migrator.migrate(Repo, User)
    updated = Repo.one(from(u in "users", select: [:id, :name, :email, :email_hash]))
    [updated: updated]
  end

  describe ".migrate/2" do
    setup [:create_user, :migrate]

    test "migrates cloak fields to default cipher", %{user: user, updated: updated} do
      assert updated.email != user.email, ":email was not migrated"

      assert {:ok, @email} == decrypt(updated.email, :default),
             ":email not encrypted with default cipher"
    end

    test "leaves non-encrypted fields untouched", %{user: user, updated: updated} do
      assert updated.name == user.name
      assert updated.email_hash == user.email_hash
    end

    test "can decrypt full schema struct after fetch", %{user: user} do
      fetched = Repo.get(User, user.id)
      assert fetched.name == user.name
      assert fetched.email == @email
      assert fetched.email_hash == user.email_hash
    end

    test "raises error if repo is not an Ecto.Repo" do
      for invalid <- [:string, Vault] do
        assert_raise ArgumentError, fn ->
          Migrator.migrate(invalid, User)
        end
      end
    end

    test "raises error if schema is not an Ecto.Schema" do
      for invalid <- [:map, Vault] do
        assert_raise ArgumentError, fn ->
          Migrator.migrate(Repo, invalid)
        end
      end
    end
  end

  defp decrypt(ciphertext, label) do
    {cipher, opts} = Application.get_env(:cloak, Vault)[:ciphers][label]
    cipher.decrypt(ciphertext, opts)
  end
end
