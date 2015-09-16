defmodule Cloak.EncryptedIntegerField do
  use Cloak.EncryptedField

  def after_decrypt(value), do: String.to_integer(value)
end
