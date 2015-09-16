defmodule Cloak.SHA256Field do
  @moduledoc """
  An `Ecto.Type` which hashes the field value using the SHA256 algorithm. 

  ## Usage

  By storing a hash of a field's value, you can then query on it, because SHA256
  is deterministic and always results in the same value, whereas secure
  encryption does not. Be warned, however, that this will expose fields which
  have the same value, because they will contain the same hash.

  You should create the field with the type `:binary`. It can then be added to
  your `schema` definition like this:

      schema "table" do
        field :field_name, Cloak.EncryptedBinaryField # The field you want a hashed copy of
        field :field_name_hash, Cloak.SHA256Field
      end

  You'll also want to add `before_insert/1` and `before_update/1` callbacks to
  ensure that the field is set every time that `:field_name` changes.

      before_insert :set_field_name_hash
      before_update :set_field_name_hash

      defp set_field_name_hash(changeset) do
        put_change(changeset, :field_name_hash, get_field(changeset, :field_name))
      end
  """

  @doc false
  def type, do: :binary

  @doc false
  def cast(value) do
    {:ok, to_string(value)}
  end

  @doc false
  def dump(value) do
    {:ok, hash(value)}
  end

  @doc false
  def load(value) do
    {:ok, value}
  end

  @doc false
  def hash(value) do
    :crypto.hash(:sha256, value)
  end
end
