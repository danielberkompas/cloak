defmodule Mix.Tasks.Cloak.Migrate do
  @moduledoc """
  Migrate all configured models to your new encryption configuration.

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
  access to the correct repo, and a list of models to migrate.

  Each model should be specified in this format:

      {model_name, :encryption_field_name}

  Where `:encryption_field_name` is the name of the field the model uses to
  track it's encryption version.

      config :cloak, :migration,
        repo: MyApp.Repo,
        models: [{MyApp.Model1, :encryption_version},
                 {MyApp.Model2, :encryption_version}]

  ## Usage

      mix cloak.migrate

  The task allows you to customize the repo and models which will be migrated at
  runtime.

      mix cloak.migrate -m MyApp.Model -f encryption_version -r MyApp.Repo
  """

  use Mix.Task
  import Ecto.Query, only: [from: 2]
  import Logger, only: [info: 1]
  import String, only: [to_existing_atom: 1]

  @doc false
  def run(args) do
    info "=== Starting Migration ==="
    {repo, models} = parse(args)
    Mix.Task.run "app.start", args
    Enum.each(models, &migrate(&1, repo))
    info "=== Migration Complete ==="
  end

  defp parse(args) do
    {opts, _, _} = OptionParser.parse(args, aliases: [m: :model,
                                                      f: :field,
                                                      r: :repo])
    repo = case opts[:repo] do
      nil  -> Application.get_env(:cloak, :migration)[:repo]
      repo -> to_module(repo)
    end

    models = case opts[:model] do
      nil   -> Application.get_env(:cloak, :migration)[:models]
      model -> [{to_module(model), String.to_atom(opts[:field])}]
    end

    validate!(repo, models)

    {repo, models}
  end

  defp validate!(repo, [h|_t]) when repo == nil or not is_tuple(h) do
    raise ArgumentError, """
    You must specify which models you wish to migrate and which repo to use.

    You can do this in your Mix config, like so:

        config :cloak, :migration,
          repo: MyApp.Repo,
          models: [{MyApp.Model1, :encryption_version},
                   {MyApp.Model2, :encryption_version}]

    Alternatively, you can pass in the model, field, and repo as command line
    arguments to `mix cloak.migrate`:

        mix cloak.migrate -r Repo -m ModelName -f encryption_version_field
    """
  end
  defp validate!(_repo, _models) do
  end

  defp migrate({model, field}, repo) do
    info "--- Migrating #{inspect model} Model ---"
    ids = ids_for({model, field}, repo)
    info "#{length(ids)} records found needing migration"

    for id <- ids do
      model
      |> repo.get(id)
      |> migrate_row(repo, field)
    end
  end

  defp ids_for({model, field}, repo) do
    query = from m in model,
              where: field(m, ^field) != ^Cloak.version,
              select: m.id

    repo.all(query)
  end

  defp migrate_row(row, repo, field) do
    version = Map.get(row, field)

    if version != Cloak.version do
      row
      |> Ecto.Changeset.change
      |> Ecto.Changeset.put_change(field, Cloak.version)
      |> repo.update!
    end
  end

  defp to_module(name) do
    to_existing_atom("Elixir." <> name)
  end
end
