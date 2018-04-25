defmodule Cloak.Fields.Time do
  @moduledoc """
  An `Ecto.Type` to encrypt `Time` fields.

  ## Migration

  The database field must be of type `:binary`.

      add :encrypted_field, :binary

  ## Usage

  Define an `Encrypted.Time` module in your project:

      defmodule MyApp.Encrypted.Time do
        use Cloak.Fields.Time, vault: MyApp.Vault
      end

  Then, define the type of your desired fields:

      schema "table_name" do
        field :encrypted_field, MyApp.Encrypted.Time
      end
  """

  @doc false
  defmacro __using__(opts) do
    opts = Keyword.merge(opts, vault: Keyword.fetch!(opts, :vault))

    quote location: :keep do
      use Cloak.Field, unquote(opts)

      def cast(value), do: Ecto.Type.cast(:time, value)

      def before_encrypt(value) do
        case Ecto.Type.cast(:time, value) do
          {:ok, time} -> to_string(time)
          _error -> :error
        end
      end

      def after_decrypt(value) do
        case Time.from_iso8601(value) do
          {:ok, time} -> time
          _error -> :error
        end
      end
    end
  end
end
