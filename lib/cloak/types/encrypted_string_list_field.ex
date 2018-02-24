defmodule Cloak.EncryptedStringListField do
  @moduledoc """
  An `Ecto.Type` to encrypt a list of strings.

  ## Configuration

  You can customize the json library used for for converting lists.
  Default: `Poison`

      config :cloak, json_library: Jason

  ## Usage

  You should create the field with type `:binary`. On encryption, the list
  will first be converted to JSON using the configured `:json_library`, and
  then encrypted. On decryption, the `:json_library` will be used to convert
  it back to a list of strings.

  You can use this field type in your `schema` definition like this:

      schema "table" do
        field :field_name, Cloak.EncryptedStringArrayField
      end

  Use it where you would have normally done this:

      schema "table" do
        field :field_name, {:array, :string}
      end
  """

  use Cloak.EncryptedField

  alias Cloak.Config

  def cast(value) do
    Ecto.Type.cast({:array, :string}, value)
  end

  def before_encrypt(value) do
    Config.json_library().encode!(value)
  end

  def after_decrypt(json) do
    Config.json_library().decode!(json)
  end
end
