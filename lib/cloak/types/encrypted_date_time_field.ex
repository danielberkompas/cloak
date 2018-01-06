defmodule Cloak.EncryptedDateTimeField do
  @moduledoc """
  An `Ecto.Type` to encrypt `DateTime` fields.

  ## Usage

  You should create the field with the type `:binary`.
  Values will be converted back to a `DateTime` on decryption.

      schema "table" do
        field :field_name, Cloak.EncryptedDateTimeField
      end
  """

  use Cloak.EncryptedField

  def cast(value), do: Ecto.Type.cast(:utc_datetime, value)

  def before_encrypt(value) do
    case Ecto.Type.cast(:utc_datetime, value) do
      {:ok, dt} -> to_string(dt)
      _error -> :error
    end
  end

  def after_decrypt(value) do
    case DateTime.from_iso8601(value) do
      {:ok, dt, _offset} -> dt
      _error -> :error
    end
  end
end
