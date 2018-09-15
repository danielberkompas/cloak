defmodule Cloak.Migrator.CursorStream do
  @moduledoc false
  # Returns a stream of primary key values from a database table associated
  # with an Ecto.Schema.
  #
  # Uses a multi-field cursor to page through the table, so as not to rely on
  # sequential integer IDs to find all rows.

  import Ecto.Query

  def new(repo, schema, limit) do
    Stream.resource(
      fn ->
        [primary_key | _] = schema.__schema__(:primary_key)
        cursor_fields = fields_for_cursor(schema, primary_key)

        select_fields =
          [primary_key]
          |> Enum.concat(cursor_fields)
          |> Enum.uniq()

        query =
          schema
          |> select(^select_fields)
          |> order_by(^cursor_fields)

        cursor_record =
          query
          |> first()
          |> repo.one()

        %{
          results: [Map.get(cursor_record, primary_key)],
          repo: repo,
          schema: schema,
          query: query,
          cursor: Map.take(cursor_record, cursor_fields),
          cursor_fields: cursor_fields,
          primary_key: primary_key,
          limit: limit
        }
      end,
      &next/1,
      fn _config -> :ok end
    )
  end

  defp next(%{cursor: nil} = config) do
    {:halt, config}
  end

  defp next(%{results: [head | tail]} = config) do
    {[head], %{config | results: tail}}
  end

  defp next(%{results: []} = config) do
    results =
      config
      |> query_by_cursor()
      |> limit(^config.limit)
      |> config.repo.all()

    case length(results) do
      0 ->
        {:halt, config}

      _ ->
        new_cursor =
          results
          |> List.last()
          |> Map.take(config.cursor_fields)

        [head | tail] = Enum.map(results, &Map.get(&1, config.primary_key))
        {[head], %{config | cursor: new_cursor, results: tail}}
    end
  end

  defp fields_for_cursor(schema, primary_key) do
    if function_exported?(schema, :__cloak_cursor_fields__, 0) do
      schema.__cloak_cursor_fields__
    else
      [primary_key]
    end
  end

  defp query_by_cursor(config) do
    Enum.reduce(config.cursor_fields, config.query, fn field, query ->
      cursor_filter(query, field, config.schema.__schema__(:type, field), config.cursor[field])
    end)
  end

  defp cursor_filter(query, field, type, value)
       when type in [:utc_datetime, :naive_datetime, :date, :time] do
    where(query, [s], field(s, ^field) >= ^value)
  end

  defp cursor_filter(query, field, _type, value) do
    where(query, [s], field(s, ^field) > ^value)
  end
end
