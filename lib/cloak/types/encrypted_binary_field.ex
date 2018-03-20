defmodule Cloak.EncryptedBinaryField do
  @moduledoc """
  An `Ecto.Type` to encrypt a binary field.

  ## Usage

      defmodule MyApp.EncryptedBinaryField do
        use Cloak.EncryptedBinaryField, vault: MyApp.Vault
      end
  """

  @doc false
  defmacro __using__(opts) do
    opts = Keyword.merge(opts, vault: Keyword.fetch!(opts, :vault))

    quote do
      use Cloak.EncryptedField, unquote(opts)
    end
  end
end
