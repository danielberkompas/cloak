defmodule Cloak.EncryptedMapField do
  @moduledoc """
  An `Ecto.Type` to encrypt maps.

  ## Configuration

  You can customize the json library used for for converting maps.
  Default: `Poison`

      config :cloak, json_library: Jason

  ## Usage

  You should create the field with type `:binary`. On encryption, the map
  will first be converted to JSON using the configured `:json_library`, and
  then encrypted. On decryption, the `:json_library` will be used to convert
  it back to a map.

  This means that on decryption, atom keys will become string keys.

      %{hello: "world"}

  Will become:

      %{"hello" => "world"}

  You can use this field type in your `schema` definition like this:

      schema "table" do
        field :field_name, Cloak.EncryptedMapField
      end
  """

  use Cloak.EncryptedField

  alias Cloak.Config

  def cast(value) do
    Ecto.Type.cast(:map, value)
  end

  def before_encrypt(value) do
    Config.json_library().encode!(value)
  end

  def after_decrypt(json) do
    Config.json_library().decode!(json)
  end
end
