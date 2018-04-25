defmodule Cloak.Fields.Binary do
  @moduledoc """
  An `Ecto.Type` to encrypt a binary field.

  ## Migration

  The database field must be of type `:binary`.

      add :encrypted_field, :binary

  ## Usage

  Define an `Encrypted.Binary` module in your project:

      defmodule MyApp.Encrypted.Binary do
        use Cloak.Fields.Binary, vault: MyApp.Vault
      end

  Then, define the type of your desired fields:

      schema "table_name" do
        field :encrypted_field, MyApp.Encrypted.Binary
      end
  """

  @doc false
  defmacro __using__(opts) do
    opts = Keyword.merge(opts, vault: Keyword.fetch!(opts, :vault))

    quote location: :keep do
      use Cloak.Field, unquote(opts)

      def cast(value) do
        Ecto.Type.cast(:string, value)
      end
    end
  end
end
