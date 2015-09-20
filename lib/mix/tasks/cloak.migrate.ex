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
  access to the correct repo. You can configure this with the `:repo` option in
  Cloak's OTP configuration:

      config :cloak, repo: MyApp.Repo

  Every model which `use`s `Cloak.Model` will automatically be migrated.

  ## Usage

      mix cloak.migrate

  The task allows you to customize the repo and models which will be migrated at
  runtime.

      mix cloak.migrate --model MyApp.Model --repo MyApp.Repo
      mix cloak.migrate -m MyApp.Model -r MyApp.Repo
  """

  use Mix.Task
  import Ecto.Query, only: [from: 2]
  import Logger, only: [info: 1]
  import String, only: [to_existing_atom: 1]

  @config  Application.get_all_env(:cloak)
  @repo    @config[:repo]
  @models  @config[:models] || []
  @version Cloak.version

  @doc false
  def run(args) do
    info "=== Starting Migration ==="
    {repo, models} = parse_args(args)
    Mix.Task.run "app.start", args
    Enum.each(models, &migrate(&1, repo))
    info "=== Migration Complete ==="
  end

  defp parse_args(args) do
    {opts, _, _} = OptionParser.parse(args, aliases: [m: :model, r: :repo])

    repo = case opts[:repo] do
      nil   -> @repo
      other -> to_existing_atom(other)
    end

    models = case opts[:model] do
      nil   -> @models
      other -> [to_existing_atom(other)]
    end

    {repo, models}
  end

  defp migrate(model, repo) do
    info "--- Migrating #{model} Model ---"
    ids = ids_for(model, repo)
    info "#{length(ids)} records found needing migration"

    for id <- ids do
      repo.get(model, id) |> migrate_row(repo)
    end
  end

  defp ids_for(model, repo) do
    query = from m in model, 
              where: field(m, ^model.__encryption_version_field__) != ^@version,
              select: m.id

    repo.all(query)
  end

  defp migrate_row(row, repo) do
    version = Map.get(row, row.__struct__.__encryption_version_field__)

    if version != @version do
      repo.update!(row)
    end
  end
end
