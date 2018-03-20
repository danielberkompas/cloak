defmodule Cloak.EncryptedIntegerListField do
  @moduledoc """
  An `Ecto.Type` to encrypt a list of integers.

  ## Configuration

  You can customize the json library used for for converting the lists.

      config :my_app, MyApp.Vault,
        json_library: Jason

  ## Usage

      defmodule MyApp.EncryptedIntegerListField do
        use Cloak.EncryptedIntegerListField, vault: MyApp.Vault
      end
  """

  @doc false
  defmacro __using__(opts) do
    opts = Keyword.merge(opts, vault: Keyword.fetch!(opts, :vault))

    quote location: :keep do
      use Cloak.EncryptedField, unquote(opts)

      alias Cloak.Config

      def cast(value) do
        Ecto.Type.cast({:array, :integer}, value)
      end

      def before_encrypt(value) do
        Config.json_library().encode!(value)
      end

      def after_decrypt(json) do
        Config.json_library().decode!(json)
      end
    end
  end
end
