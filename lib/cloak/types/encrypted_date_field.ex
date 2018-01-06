defmodule Cloak.EncryptedDateField do
  @moduledoc """
  An `Ecto.Type` to encrypt `Date` fields.

  ## Usage

  You should create the field with the type `:binary`.
  Values will be converted back to `Date`s on decryption.

      schema "table" do
        field :field_name, Cloak.EncryptedDateField
      end
  """

  use Cloak.EncryptedField

  def cast(value), do: Ecto.Type.cast(:date, value)

  def before_encrypt(value) do
    case Ecto.Type.cast(:date, value) do
      {:ok, date} -> to_string(date)
      _error -> :error
    end
  end

  def after_decrypt(value) do
    case Date.from_iso8601(value) do
      {:ok, date} -> date
      _error -> :error
    end
  end
end
