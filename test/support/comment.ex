defmodule Cloak.TestComment do
  use Ecto.Schema

  embedded_schema do
    field(:author, :string)
    field(:body, :string)
  end
end
