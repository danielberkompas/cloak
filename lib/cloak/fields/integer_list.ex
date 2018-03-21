defmodule Cloak.Fields.IntegerList do
  @moduledoc """
  An `Ecto.Type` to encrypt a list of integers.

  ## Configuration

  You can customize the json library used for for converting the lists.

      config :my_app, MyApp.Vault,
        json_library: Jason

  ## Usage

      defmodule MyApp.Encrypted.IntegerList do
        use Cloak.Fields.IntegerList, vault: MyApp.Vault
      end
  """

  @doc false
  defmacro __using__(opts) do
    opts = Keyword.merge(opts, vault: Keyword.fetch!(opts, :vault))

    quote location: :keep do
      use Cloak.Field, unquote(opts)

      alias Cloak.Config

      def cast(value) do
        Ecto.Type.cast({:array, :integer}, value)
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
