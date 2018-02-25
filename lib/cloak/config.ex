defmodule Cloak.Config do
  @moduledoc false

  @spec all() :: Keyword.t()
  def all() do
    Enum.filter(Application.get_all_env(:cloak), fn {key, _} ->
      cipher?(key)
    end)
  end

  @spec json_library :: module
  def json_library do
    Application.get_env(:cloak, :json_library, Poison)
  end

  @spec cipher(String.t()) :: {module, Keyword.t()}
  def cipher(tag) do
    # TODO Should we throw here if we can't find?
    Enum.find(all(), fn {_cipher, opts} ->
      opts[:tag] == tag
    end)
  end

  @spec default_cipher() :: {module, Keyword.t()}
  def default_cipher() do
    cipher =
      Enum.find(all(), fn {_cipher, opts} ->
        opts[:default] == true
      end)

    unless cipher do
      raise """
      Please specify a default cipher in your mix configuration. See `Cloak`'s
      documentation to find out how.
      """
    end

    cipher
  end

  defp cipher?(module) do
    Cloak.Cipher in Keyword.get(attributes_for(module), :behaviour, [])
  end

  defp attributes_for(module) do
    try do
      module.__info__(:attributes)
    rescue
      UndefinedFunctionError -> []
    end
  end
end
