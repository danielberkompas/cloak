defmodule Cloak.SHA256Field do
  @moduledoc """
  An `Ecto.Type` which hashes the field value using the SHA256 algorithm. 

  ## Usage

  By storing a hash of a field's value, you can then query on it as a proxy 
  for the encrypted field because SHA256 is deterministic and always results 
  in the same value, whereas secure encryption does not. Be warned, however, 
  that this will expose fields which have the same value, because they will 
  contain the same hash.

  You should create the hash field with the type `:binary`. It can then be added to
  your `schema` definition like this:

      schema "table" do
        field :field_name, Cloak.EncryptedBinaryField # The field you want a hashed copy of
        field :field_name_hash, Cloak.SHA256Field
      end

  In versions of Ecto < 2.0 you'll also want to add `before_insert/1` and `before_update/1` callbacks to
  ensure that the field is set every time that `:field_name` changes.

      before_insert :set_field_name_hash
      before_update :set_field_name_hash

      defp set_field_name_hash(changeset) do
        put_change(changeset, :field_name_hash, get_field(changeset, :field_name))
      end
      
  In Ecto versions > 2.0 callbacks have been removed so you will need to use the `prepare_changes/2` function
  on the changeset to ensure that the fields stay in sync every time `:field_name` changes.
  
      def changeset(struct, params \\ %{}) do
        struct
        |> cast(params, [:field_name, :field_name_hash])
        |> prepare_changes(fn changeset ->
            changeset
            |> put_change(:field_name_hash, get_field(changeset, :field_name))
           end)
      end
      
  You should then be able to query the Repo using the `:field_name_hash` in any place you would typically query by `:field_name`.
  
      user = Repo.get_by(User, field_name_hash: "query")
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
