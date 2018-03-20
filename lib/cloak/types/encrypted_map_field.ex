defmodule Cloak.EncryptedMapField do
  @moduledoc """
  An `Ecto.Type` to encrypt maps.

  ## Configuration

  You can customize the json library used for for converting the lists.

      config :my_app, MyApp.Vault,
        json_library: Jason

  ## Usage

      defmodule MyApp.EncryptedMapField do
        use Cloak.EncryptedMapField, vault: MyApp.Vault
      end

  You should create the field with type `:binary`. On encryption, the map
  will first be converted to JSON using the configured `:json_library`, and
  then encrypted. On decryption, the `:json_library` will be used to convert
  it back to a map.

  This means that on decryption, atom keys will become string keys.

      %{hello: "world"}

  Will become:

      %{"hello" => "world"}
  """

  defmacro __using__(opts) do
    opts = Keyword.merge(opts, vault: Keyword.fetch!(opts, :vault))

    quote location: :keep do
      use Cloak.EncryptedField, unquote(opts)

      alias Cloak.Config

      def cast(value) do
        Ecto.Type.cast(:map, value)
      end

      def before_encrypt(value) do
        unquote(opts[:vault]).json_library().encode!(value)
      end

      def after_decrypt(json) do
        unquote(opts[:vault]).json_library().decode!(json)
      end
    end
  end
end
