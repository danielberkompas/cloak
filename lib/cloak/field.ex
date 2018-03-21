defmodule Cloak.Field do
  @moduledoc false

  defmacro __using__(opts) do
    vault = Keyword.fetch!(opts, :vault)
    label = opts[:label]

    quote location: :keep do
      @doc false
      def type, do: :binary

      @doc false
      def cast(value) do
        {:ok, value}
      end

      @doc false
      def dump(value) do
        with value <- before_encrypt(value),
             {:ok, value} <- encrypt(value) do
          {:ok, value}
        else
          _other ->
            :error
        end
      end

      @doc false
      def load(value) do
        with {:ok, value} <- decrypt(value) do
          value = after_decrypt(value)
          {:ok, value}
        else
          _other ->
            :error
        end
      end

      @doc false
      def before_encrypt(value), do: to_string(value)

      @doc false
      def after_decrypt(value), do: value

      defoverridable Module.definitions_in(__MODULE__)

      defp encrypt(plaintext) do
        if unquote(label) do
          unquote(vault).encrypt(plaintext, unquote(label))
        else
          unquote(vault).encrypt(plaintext)
        end
      end

      defp decrypt(ciphertext) do
        unquote(vault).decrypt(ciphertext)
      end
    end
  end
end
