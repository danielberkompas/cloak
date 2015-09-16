defmodule Cloak.EncryptedMapField do
  @moduledoc """
  An `Ecto.Type` to encrypt maps.

  ## Usage

  You should create the field with type `:binary`. On encryption, the map will
  first be converted to JSON using `Poison.encode/1`, and then encrypted. On
  decryption, `Poison.decode/1` will be used to convert it back to a map.

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

  def before_encrypt(value) do 
    {:ok, json} = Poison.encode(value)
    json
  end

  def after_decrypt(json) do 
    {:ok, value} = Poison.decode(json)
    value
  end
end
