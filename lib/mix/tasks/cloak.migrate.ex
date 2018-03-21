defmodule Mix.Tasks.Cloak.Migrate do
  @moduledoc """
  Migrate all configured schemas to your new encryption configuration.

  While Cloak will automatically decrypt rows which use an old decryption cipher
  or key, this isn't usually enough. Usually, you want to retire the old key, so
  it won't do to leave it configured indefinitely.

  This task allows you to proactively upgrade all rows in your database to the
  new encryption configuration, so that you can remove the old key.

  ## Before You Run This Task...

  1. Ensure that you have configured your new encryption cipher.
  2. Set the new cipher and/or key as the `:default`. Otherwise, running this
  task will have no effect.

  ## Configuration

  In order for the Mix task to update rows in the correct database, it must have
  access to the correct repo, and a list of schemas to migrate.

  Each schema should be specified in one of the following formats:

      {schema_name}
      {schema_name, :encrypted_field_name}
      {schema_name, [:encrypted_field_name, :other_encrypted_field_name}

  Where `:encrypted_field_name` is a field that's of type the Cloak.Encrypted*

      config :cloak, :migration,
        repo: MyApp.Repo,
        schemas: [{MyApp.Schema1},
                  {MyApp.Schema2, :encryption_version},
                  {MyApp.Schema2, [:encrypted_field_name, :other_encrypted_field_name]},
                 ]

  ## Usage

      mix cloak.migrate

  The task allows you to customize the repo and schemas which will be migrated at
  runtime.

      mix cloak.migrate -m MyApp.Schema -f encryption_version -r MyApp.Repo
  """

  @shortdoc """
  Migrate all configured schemas to your new encryption configuration.
  """

  use Mix.Task, only: [from: 2, ^: 1]
  import Ecto.Query
  import Logger, only: [info: 1]
  import String, only: [to_existing_atom: 1]

  @doc false
  def run(args) do
    _ = info("=== Starting Migration ===")
    {repo, schemas} = parse(args)
    Mix.Task.run("app.start", args)
    Enum.each(schemas, &migrate(elem(&1, 0), elem(&1, 1), repo))
    _ = info("=== Migration Complete ===")

    :ok
  end

  defp parse(args) do
    {opts, _, _} = OptionParser.parse(args, aliases: [m: :schema, f: :field, r: :repo])

    repo =
      case opts[:repo] do
        nil -> Application.get_env(:cloak, :migration)[:repo]
        repo -> to_module(repo)
      end

    schemas =
      case opts[:schema] do
        nil -> Application.get_env(:cloak, :migration)[:schemas]
        schema -> [{to_module(schema), String.to_atom(opts[:field])}]
      end

    validate!(repo, schemas)

    {repo, schemas}
  end

  defp validate!(repo, [h | _t]) when repo == nil or not is_tuple(h) do
    raise ArgumentError, """
    You must specify which schemas you wish to migrate and which repo to use.

    You can do this in your Mix config, like so:

        config :cloak, :migration,
          repo: MyApp.Repo,
          schemas: [{MyApp.Schema1, :encryption_version},
                   {MyApp.Schema2, :encryption_version}]

    Alternatively, you can pass in the schema, field, and repo as command line
    arguments to `mix cloak.migrate`:

        mix cloak.migrate -r Repo -m SchemaName -f encryption_version_field
    """
  end

  defp validate!(_repo, _schemas), do: :ok

  defp migrate(schema, repo) do
    types = [
      Cloak.EncryptedBinaryField,
      Cloak.EncryptedDateField,
      Cloak.EncryptedDateTimeField,
      Cloak.EncryptedField,
      Cloak.EncryptedFloatField,
      Cloak.EncryptedIntegerField,
      Cloak.EncryptedIntegerListField,
      Cloak.EncryptedMapField,
      Cloak.EncryptedNaiveDateTimeField,
      Cloak.EncryptedStringListField,
      Cloak.EncryptedTimeField,
      Cloak.SHA256Field
    ]

    schema
    |> migrate(
      schema.__schema__(:fields)
      |> Enum.filter(&Enum.member?(types, schema.__schema__(:type, &1))),
      repo
    )
  end

  defp migrate(schema, [_ | _] = fields, repo) do
    _ = info("--- Migrating #{inspect(schema)} Schema ---")
    ids = ids_needing_migration(schema, fields, repo)
    _ = info("#{length(ids)} records found needing migration")

    for id <- ids do
      schema
      |> repo.get(id)
      |> migrate_row(repo, fields)
    end
  end

  defp migrate(schema, field, repo) do
    migrate(schema, [field], repo)
  end

  def migrate_row(row, repo, fields) do
    changeset =
      row
      |> Ecto.Changeset.change()

    changeset
    |> force_reencryption(fields)
    |> repo.update!
  end

  def ids_needing_migration(schema, [_ | _] = fields, repo) do
    # Finds all records that don't have a prefix matching the current Cloak.version() in any of the fields passed in
    cloak_version = Cloak.version()
    prefix_length = String.length(Cloak.version()) + 1

    query =
      from(
        m in schema,
        select: m.id
      )

    fields
    |> Enum.reduce(query, fn field, query_accumulator ->
      query_accumulator
      |> or_where(
        [m],
        fragment("substring(?, ?, ?)", field(m, ^field), 0, ^prefix_length) != ^cloak_version
      )
    end)
    |> repo.all()
  end

  def ids_needing_migration(schema, field, repo) do
    ids_needing_migration(schema, [field], repo)
  end

  defp force_reencryption(changeset, fields) do
    fields
    |> Enum.reduce(changeset, fn field, acc_changeset ->
      acc_changeset
      |> Ecto.Changeset.force_change(
        field,
        acc_changeset
        |> Ecto.Changeset.fetch_field(field)
        |> elem(1)
      )
    end)
  end

  defp to_module(name) do
    to_existing_atom("Elixir." <> name)
  end
end
