defmodule Cloak.EncryptedFloatField do
  use Cloak.EncryptedField

  def after_decrypt(value), do: String.to_float(value)
end
