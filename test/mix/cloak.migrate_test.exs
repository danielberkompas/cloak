defmodule Cloak.MigrateTest do
  use Cloak.DataCase, async: false

  import ExUnit.CaptureIO
  import IO.ANSI, only: [yellow: 0, green: 0, reset: 0]

  setup do
    [user: Factory.create_user("test@email.com")]
  end

  test "migrates existing rows to new version when command line args given" do
    output =
      capture_io(fn ->
        Mix.Task.rerun("cloak.migrate", [
          "-r",
          "Cloak.TestRepo",
          "-s",
          "Cloak.TestUser"
        ])
      end)

    assert output == """
           Migrating #{yellow()}Cloak.TestUser#{reset()}...
           #{green()}Migration complete!#{reset()}
           """
  end

  test "reads from configuration" do
    Application.put_env(:cloak, :cloak_repo, Cloak.TestRepo)
    Application.put_env(:cloak, :cloak_schemas, [Cloak.TestUser])

    output =
      capture_io(fn ->
        Mix.Task.rerun("cloak.migrate", [])
      end)

    assert output == """
           Migrating #{yellow()}Cloak.TestUser#{reset()}...
           #{green()}Migration complete!#{reset()}
           """

    Application.delete_env(:cloak, :cloak_repo)
    Application.delete_env(:cloak, :cloak_schemas)
  end

  test "raises error if called with incorrect arguments" do
    bad_args = [
      [],
      ["-r", "Cloak.TestRepo"],
      ["-s", "Cloak.TestSchema"]
    ]

    for args <- bad_args do
      assert_raise Mix.Error, fn ->
        Mix.Task.rerun("cloak.migrate", args)
      end
    end
  end
end
