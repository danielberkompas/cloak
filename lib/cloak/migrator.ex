defmodule Cloak.Migrator do
  @moduledoc false

  import Ecto.Query

  alias Ecto.Changeset
  alias Cloak.Migrator.CursorStream

  def migrate(repo, schema) when is_atom(repo) and is_atom(schema) do
    validate(repo, schema)

    [primary_key | _] = schema.__schema__(:primary_key)

    case repo.aggregate(schema, :count, primary_key) do
      0 -> :ok
      _ -> migrate_schema_with_data(repo, schema)
    end
  end

  defp migrate_schema_with_data(repo, schema) do
    fields = cloak_fields(schema)

    repo
    |> CursorStream.new(schema, 100)
    |> Flow.from_enumerable(stages: System.schedulers_online())
    |> Flow.map(&migrate_row(&1, repo, schema, fields))
    |> Flow.run()
  end

  defp migrate_row(id, repo, schema, fields) do
    [primary_key | _] = schema.__schema__(:primary_key)

    repo.transaction(fn ->
      query =
        schema
        |> where([s], field(s, ^primary_key) == ^id)
        |> lock("FOR UPDATE")

      case repo.one(query) do
        nil ->
          :noop

        row ->
          row
          |> force_changes(fields)
          |> repo.update()
      end
    end)
  end

  defp force_changes(row, fields) do
    Enum.reduce(fields, Changeset.change(row), fn field, changeset ->
      Changeset.force_change(changeset, field, Map.get(row, field))
    end)
  end

  defp cloak_fields(schema) do
    :fields
    |> schema.__schema__()
    |> Enum.map(fn field ->
      {field, schema.__schema__(:type, field)}
    end)
    |> Enum.filter(fn {_field, type} ->
      Code.ensure_loaded?(type) && function_exported?(type, :__cloak__, 0)
    end)
    |> Enum.map(fn {field, _type} ->
      field
    end)
  end

  defp validate(repo, schema) do
    unless ecto_repo?(repo) do
      raise ArgumentError, "#{inspect(repo)} is not an Ecto.Repo"
    end

    unless ecto_schema?(schema) do
      raise ArgumentError, "#{inspect(schema)} is not an Ecto.Schema"
    end
  end

  defp ecto_repo?(repo) do
    Code.ensure_loaded?(repo) && function_exported?(repo, :__adapter__, 0)
  end

  defp ecto_schema?(schema) do
    Code.ensure_loaded?(schema) && function_exported?(schema, :__schema__, 1)
  end
end
