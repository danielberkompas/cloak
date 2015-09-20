defmodule Cloak.Model do
  @moduledoc """
  Track what encryption configuration was used to encrypt a given Ecto model.

  ## How to Use

  Add a binary field to your Ecto module. It should be indexed, so that you can
  easily query on it.

      schema "table" do
        field :encryption_version, :binary
      end

  You can then `use` this module, specifying the `:encryption_version` field as
  the one to store the value on:

      use Cloak.Model, :encryption_version

  The `:encryption_version` field will then automatically be reset with the
  current value of `Cloak.version/0` every time a row is inserted or updated.
  """

  @doc false
  defmacro __using__(field_name) when is_atom(field_name) do
    quote do
      before_insert :set_cloak_encryption_version
      before_update :set_cloak_encryption_version

      def set_cloak_encryption_version(changeset) do
        put_change(changeset, unquote(field_name), Cloak.version)
      end

      def __encryption_version_field__, do: unquote(field_name)
    end
  end

  defmacro __using__(_invalid) do
    raise ArgumentError, """
    You didn't specify a field for Cloak.Model to automatically update with the
    current encryption version. For example:

        use Cloak.Model, :encryption_version
    """
  end
end
