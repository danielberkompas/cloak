defmodule Cloak.TestPost do
  use Ecto.Schema

  @primary_key {:id, :binary_id, autogenerate: true}

  schema "posts" do
    field(:title, Cloak.Test.Encrypted.Binary)
    timestamps(type: :utc_datetime)
  end
end
