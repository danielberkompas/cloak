defmodule Cloak.CustomCursor do
  @moduledoc """
  Defines a list of fields to use as a cursor when migrating a schema's table
  to a new encryption key using `mix cloak.migrate`.

  ## When to Use This

  This behaviour is useful in rare situations where your primary key cannot
  be used as a cursor to page through the table. You need this if primary key
  cannot meet the "Column Requirements" below.

  For example, you don't need to use this module if your primary key is:

  - An integer
  - A PostgreSQL UUID
  - A MongoDB ObjectID
  - Your primary key already meets the "Column Requirements"

  ## Column Requirements

  Each column you specify for the cursor must meet the following
  requirements:

  - Each column must contain sortable values
  - Each column must be comparable using the `>` operator
  - The combined value of the columns must be unique in the table

  ## Example

      defmodule MyApp.MySchema do
        use Ecto.Schema

        @behaviour Cloak.CustomCursor

        schema "table" do
          # ...
        end

        @impl Cloak.CustomCursor
        def __cloak_cursor_fields__ do
          [:sequential_id, :inserted_at]
        end
      end
  """

  @doc """
  Returns a list of cursor fields.

  ## Example

      @impl Cloak.CustomCursor
      def __cloak_cursor_fields__ do
        [:sequential_id, :inserted_at]
      end
  """
  @callback __cloak_cursor_fields__ :: [atom]
end
