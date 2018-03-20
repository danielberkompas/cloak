defmodule Cloak.EncryptedFloatField do
  @moduledoc """
  An `Ecto.Type` to encrypt a float field.

  ## Usage

      defmodule MyApp.EncryptedFloatField do
        use Cloak.EncryptedFloatField, vault: MyApp.Vault
      end
  """

  @doc false
  defmacro __using__(opts) do
    opts = Keyword.merge(opts, vault: Keyword.fetch!(opts, :vault))

    quote do
      use Cloak.EncryptedField, unquote(opts)

      def cast(value) do
        Ecto.Type.cast(:float, value)
      end

      def after_decrypt(value), do: String.to_float(value)
    end
  end
end
