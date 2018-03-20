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
      encryption_version: "AES"
    }

    def get(_, _id) do
      @schema
    end

    def all(_query) do
      [@schema]
    end

    def update!(changeset) do
      send(self(), {:changeset, changeset})
    end
  end

  import ExUnit.CaptureIO

  setup do
    Logger.disable(self())
    :ok
  end

  test "migrates existing rows to new version" do
    output =
      capture_io(fn ->
        run("cloak.migrate", [
          "-v",
          "Cloak.TestVault",
          "-r",
          "Cloak.MigrateTest.Repo",
          "-m",
          "Cloak.MigrateTest.Schema",
          "-f",
          "encryption_version"
        ])
      end)

    assert output == """
           Migrating Cloak.MigrateTest.Schema using:

             vault: Cloak.TestVault
             repo:  Cloak.MigrateTest.Repo
             field: :encryption_version

           #{IO.ANSI.green()}Migration complete!#{IO.ANSI.reset()}
           """

    assert_received {:changeset, changeset}
    assert Ecto.Changeset.get_change(changeset, :encryption_version) == Cloak.TestVault.version()
  end

  defp run(task, args) do
    Mix.Task.run(task, args)
    Mix.Task.reenable(task)
  end
end
