defmodule Cloak.EncryptedDateTimeField do
  @moduledoc """
  An `Ecto.Type` to encrypt `DateTime` fields.

  ## Usage

      defmodule MyApp.EncryptedDateTimeField do
        use Cloak.EncryptedDateTimeField, vault: MyApp.Vault
      end
  """

  defmacro __using__(opts) do
    opts = Keyword.merge(opts, vault: Keyword.fetch!(opts, :vault))

    quote do
      use Cloak.EncryptedField, unquote(opts)

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
