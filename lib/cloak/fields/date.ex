defmodule Cloak.Fields.Date do
  @moduledoc """
  An `Ecto.Type` to encrypt `Date` fields.

  ## Migration

  The database field must be of type `:binary`.

      add :encrypted_field, :binary

  ## Usage

  Define an `Encrypted.Date` module in your project:

      defmodule MyApp.Encrypted.Date do
        use Cloak.Fields.Date, vault: MyApp.Vault
      end

  Then, define the type of your desired fields:

      schema "table_name" do
        field :encrypted_field, MyApp.Encrypted.Date
      end
  """

  defmacro __using__(opts) do
    opts = Keyword.merge(opts, vault: Keyword.fetch!(opts, :vault))

    quote do
      use Cloak.Field, unquote(opts)

      def cast(value), do: Ecto.Type.cast(:date, value)

      def before_encrypt(value) do
        case Ecto.Type.cast(:date, value) do
          {:ok, date} -> to_string(date)
          _error -> :error
        end
      end

      def after_decrypt(value) do
        case Date.from_iso8601(value) do
          {:ok, date} -> date
          _error -> :error
        end
      end
    end
  end
end
