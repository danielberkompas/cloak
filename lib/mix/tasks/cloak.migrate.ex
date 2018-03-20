defmodule Mix.Tasks.Cloak.Migrate do
  @moduledoc """
  Migrates a schema table to a new encryption cipher.

  While Cloak vaults will automatically decrypt rows which use an old
  decryption cipher or key, this isn't usually enough. Usually, you want to
  retire the old key, so it won't do to leave it configured indefinitely.

  This task allows you to proactively upgrade all rows in your database to the
  new encryption configuration, so that you can remove the old key.

  ## Before You Run This Task...

  Ensure that you have configured your vault to use the new cipher by default!

      # If using mix configuration...

      config :my_app, MyApp.Vault,
        ciphers: [
          # This is the new key that you want to use
          default: {Cloak.Cipher.AES.GCM, tag: "NEW", key: <<...>>},
          # This is the old key that you want to retire
          retired: {Cloak.Cipher.AES.CTR, tag: "OLD", key: <<...>>>}
        ]

      # If configuring in the `init/1` callback:

      defmodule MyApp.Vault do
        use Cloak.Vault, otp_app: :my_app

        @impl Cloak.Vault
        def init(config) do
          config =
            Keyword.put(config, :ciphers, [
              # This is the new key that you want to use
              default: {Cloak.Cipher.AES.GCM, tag: "NEW", key: <<...>>},
              # This is the old key that you want to retire
              retired: {Cloak.Cipher.AES.CTR, tag: "OLD", key: <<...>>>}
            ])

          {:ok, config}
        end
      end

  ## Usage

      mix cloak.migrate -v MyApp.Vault -r MyApp.Repo -m MyApp.Schema -f encryption_version

  You must specify the vault, repo, schema, and encryption version field.

  The version field is used to determine which rows need to be migrated to
  the new key. It should be updated each time a row is changed, using your
  changeset function:

      def changeset(struct, attrs \\ %{}) do
        # ...
        |> put_change(:encryption_version, MyApp.Vault.version())
      end

  ### Migrating Multiple Schemas at Once

  You can migrate multiple schemas with one command using Mix aliases. Update
  your `mix.exs` aliases like so:

      # update your project/0 function:
      def project do
        [
          # ...
          aliases: aliases()
        ]
      end

      defp aliases do
        [
          "cloak.migrate_all": [
            "cloak.migrate -v MyApp.Vault -r MyApp.Repo -m MyApp.Schema1 -f encryption_version",
            "cloak.migrate -v MyApp.Vault -r MyApp.Repo -m MyApp.Schema2 -f encryption_version",
          ]
        ]
      end

  Then run `mix cloak.migrate_all` to migrate all your schemas.
  """

  use Mix.Task
  import Ecto.Query, only: [from: 2]

  @doc false
  def run(args) do
    # Ensure repo is running
    Mix.Task.run("app.start", [])
    opts = parse(args)

    Mix.shell().info("""
    Migrating #{inspect(opts.schema)} using:

      vault: #{inspect(opts.vault)}
      repo:  #{inspect(opts.repo)}
      field: #{inspect(opts.field)}
    """)

    ids = ids_for(opts.vault, opts.repo, opts.schema, opts.field)

    for id <- ids do
      opts.schema
      |> opts.repo.get(id)
      |> migrate_row(opts.vault, opts.repo, opts.field)
    end

    Mix.shell().info(IO.ANSI.green() <> "Migration complete!" <> IO.ANSI.reset())

    :ok
  end

  defp parse(args) do
    {opts, _, _} = OptionParser.parse(args, aliases: [v: :vault, m: :schema, f: :field, r: :repo])
    validate!(opts)
  end

  defp validate!(opts) do
    if opts[:vault] && opts[:repo] && opts[:schema] && opts[:field] do
      %{
        vault: to_module(opts[:vault]),
        repo: to_module(opts[:repo]),
        schema: to_module(opts[:schema]),
        field: String.to_existing_atom(opts[:field])
      }
    else
      Mix.shell().error("""
      You must specify which Vault, Repo, and Schema you wish to migrate:

          mix cloak.migrate -v MyApp.Vault -r MyApp.Repo -m MyApp.SchemaName -f encryption_version_field
      """)
    end
  end

  defp ids_for(vault, repo, schema, field) do
    query =
      from(
        m in schema,
        where: field(m, ^field) != ^vault.version(),
        select: m.id
      )

    repo.all(query)
  end

  defp migrate_row(row, vault, repo, field) do
    version = Map.get(row, field)

    if version != vault.version() do
      row
      |> Ecto.Changeset.change()
      |> Ecto.Changeset.put_change(field, vault.version())
      |> repo.update!
    end
  end

  defp to_module(name) do
    String.to_existing_atom("Elixir." <> name)
  end
end
