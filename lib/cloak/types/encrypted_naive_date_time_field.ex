defmodule Cloak.EncryptedNaiveDateTimeField do
  @moduledoc """
  An `Ecto.Type` to encrypt `NaiveDateTime` fields.

  ## Usage

      defmodule MyApp.EncryptedNaiveDateTimeField do
        use Cloak.EncryptedNaiveDateTimeField, vault: MyApp.Vault
      end
  """

  defmacro __using__(opts) do
    opts = Keyword.merge(opts, vault: Keyword.fetch!(opts, :vault))

    quote location: :keep do
      use Cloak.EncryptedField, unquote(opts)

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
