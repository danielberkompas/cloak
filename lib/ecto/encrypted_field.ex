defmodule Cloak.EncryptedField do
  defmacro __using__(_) do
    quote do
      alias Cloak.Encryptable

      def type, do: :binary

      def cast(value) do
        {:ok, value}
      end

      def dump(value) do
        value = value 
                |> before_encrypt 
                |> Cloak.encrypt

        {:ok, value}
      end

      def load(value) do
        value = value
                |> Cloak.decrypt
                |> after_decrypt

        {:ok, value}
      end

      def before_encrypt(value), do: to_string(value)
      def after_decrypt(value), do: value

      defoverridable [before_encrypt: 1, after_decrypt: 1]
    end
  end
end
