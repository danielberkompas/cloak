defmodule Cloak.EncryptedMapField do
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
