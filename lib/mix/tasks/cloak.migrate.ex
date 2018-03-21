defmodule Mix.Tasks.Cloak.Migrate do
  @moduledoc """
  Migrates a schema table to a new encryption cipher.

  ## Rationale

  Cloak vaults will automatically decrypt fields which were encrypted
  by a retired key, and reencrypt them with the new key when they change.

  However, this usually is not enough for key rotation. Usually, you want
  to proactively reencrypt all your fields with the new key, so that the
  old key can be decommissioned.

  This task allows you to do just that.

  ## Strategy

  This task will migrate a table following this strategy:

  - Query for minimum ID in the table
  - Query for maximum ID in the table
  - For each ID between, attempt to:
      - Fetch the row with that ID, locking it
      - If present, reencrypt all Cloak fields with the new cipher
      - Write the row, unlocking it

  The queries are issued in parallel to maximize speed. Each row is fetched
  and written back as quickly as possible to reduce the amount of time the
  row is locked.

  ## Warnings

  1. **IMPORTANT: `mix cloak.migrate` only works on tables with an integer, sequential
     `:id` field. This is the default setting for Ecto schemas, so it shouldn't be a
     problem for most users.**

  2. Because `mix cloak.migrate` issues queries in parallel, it can consume
     all your database connections. For this reason, you may wish to use a
     separate `Repo` with a limited `:pool` just for Cloak migrations. This will
     allow you to prevent any performance impact by throttling Cloak to use only
     a limited number of database connections.

  ## Configuration

  Ensure that you have configured your vault to use the new cipher by default!

      # If using mix configuration...

      config :my_app, MyApp.Vault,
        ciphers: [
          default: {Cloak.Ciphers.AES.GCM, tag: "NEW", key: <<...>>},
          retired: {Cloak.Ciphers.AES.CTR, tag: "OLD", key: <<...>>>}
        ]

      # If configuring in the `init/1` callback:

      defmodule MyApp.Vault do
        use Cloak.Vault, otp_app: :my_app

        @impl Cloak.Vault
        def init(config) do
          config =
            Keyword.put(config, :ciphers, [
              default: {Cloak.Ciphers.AES.GCM, tag: "NEW", key: <<...>>},
              retired: {Cloak.Ciphers.AES.CTR, tag: "OLD", key: <<...>>>}
            ])

          {:ok, config}
        end
      end

  If you want to migrate multiple schemas at once, you may find it convenient
  to specify the schemas in your `config/config.exs`:

      config :my_app,
        cloak_repo: [MyApp.Repo],
        cloak_schemas: [MyApp.Schema1, MyApp.Schema2]

  ## Usage

  To run against only a specific repo and schema, use the `-r` and `-s` flags:

      mix cloak.migrate -r MyApp.Repo -s MyApp.Schema

  If you've configured multiple schemas at once, as shown above, you can simply
  run:

      mix cloak.migrate
  """

  use Mix.Task

  import IO.ANSI, only: [yellow: 0, green: 0, reset: 0]

  alias Cloak.Migrator

  @doc false
  def run(args) do
    Mix.Task.run("app.start", [])
    configs = Mix.Cloak.parse_config(args)

    for {_app, config} <- configs,
        schema <- config.schemas do
      Mix.shell().info("Migrating #{yellow()}#{inspect(schema)}#{reset()}...")
      Migrator.migrate(config.repo, schema)
      Mix.shell().info(green() <> "Migration complete!" <> reset())
    end

    :ok
  end
end
