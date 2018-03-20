defmodule Cloak.MigrateTest do
  use ExUnit.Case

  defmodule Schema do
    use Ecto.Schema

    schema "schemas" do
      field(:encryption_version, :binary)
    end
  end

  defmodule Repo do
    @schema %Schema{
      id: 1,
      encryption_version: "AES"
    }

    def all(query) do
      query = inspect(query)
      send(self(), {:query, query})

      if String.length(query) < 70 do
        [@schema]
      else
        [1]
      end
    end

    def update!(changeset) do
      send(self(), {:changeset, changeset})
    end
  end

  import ExUnit.CaptureIO
  import Ecto.Query

  setup do
    Logger.disable(self())
    :ok
  end

  test "migrates existing rows to new version" do
    output =
      capture_io(fn ->
        Mix.Task.rerun("cloak.migrate", [
          "-v",
          "Cloak.TestVault",
          "-r",
          "Cloak.MigrateTest.Repo",
          "-s",
          "Cloak.MigrateTest.Schema",
          "-f",
          "encryption_version"
        ])
      end)

    assert output == """
           Migrating #{IO.ANSI.yellow()}Cloak.MigrateTest.Schema#{IO.ANSI.reset()} using:

             vault: #{IO.ANSI.yellow()}Cloak.TestVault#{IO.ANSI.reset()}
             repo:  #{IO.ANSI.yellow()}Cloak.MigrateTest.Repo#{IO.ANSI.reset()}
             field: #{IO.ANSI.cyan()}:encryption_version#{IO.ANSI.reset()}

           #{IO.ANSI.green()}Migration complete!#{IO.ANSI.reset()}
           """

    schema = Cloak.MigrateTest.Schema
    field = :encryption_version
    vault = Cloak.TestVault

    ids_query =
      inspect(
        from(
          m in schema,
          where: field(m, ^field) != ^vault.version(),
          or_where: is_nil(field(m, ^field)),
          select: m.id
        )
      )

    schemas_query = inspect(where(schema, [s], s.id in ^[1]))

    assert_received {:query, ^ids_query}
    assert_received {:query, ^schemas_query}

    assert_received {:changeset, changeset}
    assert Ecto.Changeset.get_change(changeset, :encryption_version) == Cloak.TestVault.version()
  end

  test "raises error if called with incorrect arguments" do
    bad_args = [
      [],
      ["-v", "Cloak.TestVault"],
      ["-v", "Cloak.TestVault", "-r", "Cloak.MigrateTest.Repo"],
      ["-v", "Cloak.TestVault", "-r", "Cloak.MigrateTest.Repo", "-s", "Cloak.MigrateTest.Schema"]
    ]

    for args <- bad_args do
      assert_raise Mix.Error, fn ->
        Mix.Task.rerun("cloak.migrate", args)
      end
    end
  end
end
