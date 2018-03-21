defmodule Cloak.Fields.Float do
  @moduledoc """
  An `Ecto.Type` to encrypt a float field.

  ## Usage

      defmodule MyApp.Encrypted.Float do
        use Cloak.Fields.Float, vault: MyApp.Vault
      end
  """

  @doc false
  defmacro __using__(opts) do
    opts = Keyword.merge(opts, vault: Keyword.fetch!(opts, :vault))

    quote do
      use Cloak.Field, unquote(opts)

      def cast(value) do
        Ecto.Type.cast(:float, value)
      end

      def after_decrypt(value), do: String.to_float(value)
    end
  end
end
