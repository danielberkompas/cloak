defmodule Cloak.EncryptedJsonField do
  use Ecto.Type
  use Cloak.EncryptedField

  def embed_as(:json), do: :dump

  def dump(value) do
    value =
      value
      |> before_encrypt()
      |> Cloak.encrypt()
      |> after_encrypt()

    {:ok, value}
  end

  def load(value) do
    value =
      value
      |> before_decrypt()
      |> Cloak.decrypt()
      |> after_decrypt()

    {:ok, value}
  end

  def after_encrypt(value), do: Base.encode64(value)

  def before_decrypt(value) do
    case Base.decode64(value) do
      {:ok, value} -> value
      {:error, error} -> {:error, error}
    end
  end
end
