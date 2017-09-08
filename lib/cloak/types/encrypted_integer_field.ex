defmodule Cloak.EncryptedIntegerField do
  @moduledoc """
  An `Ecto.Type` to encrypt integer fields. 

  ## Usage

  You should create the field with type `:binary`. Values will be converted 
  back to integers on decryption.

      schema "table" do
        field :field_name, Cloak.EncryptedIntegerField
      end
  """

  use Cloak.EncryptedField

  def cast(value) do
    Ecto.Type.cast(:integer, value)
  end

  def after_decrypt(value), do: String.to_integer(value)
end
