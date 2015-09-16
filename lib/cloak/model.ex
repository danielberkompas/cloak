defmodule Cloak.Model do
  defmacro __using__(field_name) when is_atom(field_name) do
    quote do
      before_insert :set_cloak_encryption_version
      before_update :set_cloak_encryption_version

      def set_cloak_encryption_version(changeset) do
        put_change(changeset, unquote(field_name), Cloak.version)
      end
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
