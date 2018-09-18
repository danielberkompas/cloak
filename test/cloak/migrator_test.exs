defmodule Cloak.MigratorTest do
  use Cloak.DataCase

  import ExUnit.CaptureIO

  alias Cloak.Migrator
  alias Cloak.TestUser, as: User
  alias Cloak.TestVault, as: Vault

  @email "test@email.com"

  defp create_user(_) do
    for _ <- 1..200 do
      Factory.create_user("#{32 |> :crypto.strong_rand_bytes() |> Base.encode16()}@email.com")
    end

    [user: Factory.create_user(@email)]
  end

  defp migrate(context) do
    Migrator.migrate(Repo, User)

    updated =
      from(u in "users",
        where: u.id == ^context[:user].id,
        select: [:id, :name, :email, :email_hash]
      )
      |> Repo.one()

    [updated: updated]
  end

  describe ".migrate/2 with integer IDs" do
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

  @post_title "Test Title"

  describe ".migrate/2 with binary ids" do
    setup do
      now = DateTime.utc_now()
      encrypted_title = Cloak.TestVault.encrypt!(@post_title, :secondary)
      posts = for _ <- 1..500, do: %{title: encrypted_title, inserted_at: now, updated_at: now}
      Repo.insert_all("posts", posts)

      :ok
    end

    test "migrates all the rows to the new cipher" do
      io =
        capture_io(fn ->
          Migrator.migrate(Repo, Cloak.TestPost)
        end)

      titles =
        "posts"
        |> select([:title])
        |> Repo.all()
        |> Enum.map(&decrypt(&1.title, :default))
        |> Enum.uniq()

      assert io =~ "__cloak_cursor_fields__", "Did not call __cloak_cursor_fields__ on schema!"
      assert titles == [{:ok, @post_title}], "Not all titles were migrated!"
    end
  end

  defp decrypt(ciphertext, label) do
    {cipher, opts} = Application.get_env(:cloak, Vault)[:ciphers][label]
    cipher.decrypt(ciphertext, opts)
  end
end
