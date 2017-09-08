defmodule Cloak.EncryptedBinaryField do
  @moduledoc """
  An `Ecto.Type` to encrypt a binary field.

  ## Usage

      schema "table" do
        field :field_name, Cloak.EncryptedBinaryField
      end
  """

  use Cloak.EncryptedField
end
