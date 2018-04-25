defmodule Cloak.Fields.NaiveDateTime do
  @moduledoc """
  An `Ecto.Type` to encrypt `NaiveDateTime` fields.

  ## Migration

  The database field must be of type `:binary`.

      add :encrypted_field, :binary

  ## Usage

  Define an `Encrypted.NaiveDateTime` module in your project:

      defmodule MyApp.Encrypted.NaiveDateTime do
        use Cloak.Fields.NaiveDateTime, vault: MyApp.Vault
      end

  Then, define the type of your desired fields:

      schema "table_name" do
        field :encrypted_field, MyApp.Encrypted.NaiveDateTime
      end
  """

  @doc false
  defmacro __using__(opts) do
    opts = Keyword.merge(opts, vault: Keyword.fetch!(opts, :vault))

    quote location: :keep do
      use Cloak.Field, unquote(opts)

      def cast(value), do: Ecto.Type.cast(:naive_datetime, value)

      def before_encrypt(value) do
        case Ecto.Type.cast(:naive_datetime, value) do
          {:ok, dt} -> to_string(dt)
          _error -> :error
        end
      end

      def after_decrypt(value) do
        case NaiveDateTime.from_iso8601(value) do
          {:ok, naive_dt} -> naive_dt
          _error -> :error
        end
      end
    end
  end
end
