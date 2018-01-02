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
      encryption_version: <<"AES", 5>>
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

  setup do
    Logger.disable(self())
    :ok
  end

  test "migrates existing rows to new version" do
    run("cloak.migrate", [
      "-r",
      "Cloak.MigrateTest.Repo",
      "-m",
      "Cloak.MigrateTest.Schema",
      "-f",
      "encryption_version"
    ])

    assert_changed_version()
  end

  test "uses cloak configuration if present" do
    Application.put_env(
      :cloak,
      :migration,
      repo: Repo,
      schemas: [{Schema, :encryption_version}]
    )

    run("cloak.migrate", [])

    assert_changed_version()
  end

  defp assert_changed_version do
    assert_received {:changeset, changeset}
    assert Ecto.Changeset.get_change(changeset, :encryption_version) == Cloak.version()
  end

  defp run(task, args) do
    Mix.Task.run(task, args)
    Mix.Task.reenable(task)
  end
end
