defmodule Cloak.EncryptedNaiveDateTimeField do
  @moduledoc """
  An `Ecto.Type` to encrypt naive datetime fields

  ## Usage

  You should create the field with the type `:binary`.
  Values will be converted back to a datetime on decryption

    schema "table" do
      field :field_name, Cloak.EncryptedNaiveDaTetimeField
    end
  """

  use Cloak.EncryptedField

  def cast(value), do: Ecto.Type.cast(:naive_datetime, value)

  def before_encrypt(value) do
    case Ecto.Type.cast(:naive_datetime, value) do
      {:ok, dt} -> to_string(dt)
      _error -> :error
    end
  end

  def after_decrypt(value) do
    case NaiveDateTime.from_iso8601(value) do
      {:ok, naive_dt} -> naive_dt
      _error -> :error
    end
  end
end
