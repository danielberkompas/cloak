defmodule Cloak.EncryptedDateField do
  @moduledoc """
  An `Ecto.Type` to encrypt `Date` fields.

  ## Usage

      defmodule MyApp.EncryptedDateField do
        use Cloak.EncryptedDateField, vault: MyApp.Vault
      end
  """

  defmacro __using__(opts) do
    opts = Keyword.merge(opts, vault: Keyword.fetch!(opts, :vault))

    quote do
      use Cloak.EncryptedField, unquote(opts)

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
