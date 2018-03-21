defmodule Cloak.Fields.Integer do
  @moduledoc """
  An `Ecto.Type` to encrypt integer fields.

  ## Usage

      defmodule MyApp.Encrypted.Integer do
        use Cloak.Fields.Integer, vault: MyApp.Vault
      end
  """

  @doc false
  defmacro __using__(opts) do
    opts = Keyword.merge(opts, vault: Keyword.fetch!(opts, :vault))

    quote do
      use Cloak.Field, unquote(opts)

      def cast(value) do
        Ecto.Type.cast(:integer, value)
      end

      def after_decrypt(value), do: String.to_integer(value)
    end
  end
end
