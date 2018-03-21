defmodule Cloak.Fields.Binary do
  @moduledoc """
  An `Ecto.Type` to encrypt a binary field.

  ## Usage

      defmodule MyApp.Encrypted.Binary do
        use Cloak.Fields.Binary, vault: MyApp.Vault
      end
  """

  @doc false
  defmacro __using__(opts) do
    opts = Keyword.merge(opts, vault: Keyword.fetch!(opts, :vault))

    quote location: :keep do
      use Cloak.Field, unquote(opts)
    end
  end
end
