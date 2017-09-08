defmodule Cloak.EncryptedFloatField do
  @moduledoc """
  An `Ecto.Type` to encrypt a float field.

  ## Usage

  You should create the field with type `:binary`. Values will be converted 
  back to floats on decryption.

      schema "table" do
        field :field_name, Cloak.EncryptedFloatField
      end
  """

  use Cloak.EncryptedField

  def cast(value) do
    Ecto.Type.cast(:float, value)
  end

  def after_decrypt(value), do: String.to_float(value)
end
