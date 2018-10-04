defmodule Cloak.TestPost do
  use Ecto.Schema

  @primary_key {:id, :binary_id, autogenerate: true}

  @behaviour Cloak.CustomCursor

  schema "posts" do
    field(:title, Cloak.Test.Encrypted.Binary)
    embeds_many(:comments, Cloak.TestComment)
    timestamps(type: :utc_datetime)
  end

  @impl Cloak.CustomCursor
  def __cloak_cursor_fields__ do
    IO.puts("__cloak_cursor_fields__")
    [:id, :inserted_at]
  end
end
