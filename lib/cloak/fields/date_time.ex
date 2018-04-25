defmodule Cloak.Fields.DateTime do
  @moduledoc """
  An `Ecto.Type` to encrypt `DateTime` fields.

  ## Migration

  The database field must be of type `:binary`.

      add :encrypted_field, :binary

  ## Usage

  Define an `Encrypted.DateTime` module in your project:

      defmodule MyApp.Encrypted.DateTime do
        use Cloak.Fields.DateTime, vault: MyApp.Vault
      end

  Then, define the type of your desired fields:

      schema "table_name" do
        field :encrypted_field, MyApp.Encrypted.DateTime
      end
  """

  defmacro __using__(opts) do
    opts = Keyword.merge(opts, vault: Keyword.fetch!(opts, :vault))

    quote do
      use Cloak.Field, unquote(opts)

      def cast(value), do: Ecto.Type.cast(:utc_datetime, value)

      def before_encrypt(value) do
        case Ecto.Type.cast(:utc_datetime, value) do
          {:ok, dt} -> to_string(dt)
          _error -> :error
        end
      end

      def after_decrypt(value) do
        case DateTime.from_iso8601(value) do
          {:ok, dt, _offset} -> dt
          _error -> :error
        end
      end
    end
  end
end
