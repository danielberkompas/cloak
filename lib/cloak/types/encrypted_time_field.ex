defmodule Cloak.EncryptedTimeField do
  @moduledoc """
  An `Ecto.Type` to encrypt `Time` fields.

  ## Usage

  You should create the field with the type `:binary`.
  Values will be converted back to a `Time` on decryption.

      schema "table" do
        field :field_name, Cloak.EncryptedTimeField
      end
  """

  use Cloak.EncryptedField

  def cast(value), do: Ecto.Type.cast(:time, value)

  def before_encrypt(value) do
    case Ecto.Type.cast(:time, value) do
      {:ok, time} -> to_string(time)
      _error -> :error
    end
  end

  def after_decrypt(value) do
    case Time.from_iso8601(value) do
      {:ok, time} -> time
      _error -> :error
    end
  end
end
