defmodule Cloak.Config do
  @moduledoc false
  @config Application.get_all_env(:cloak)

  def all do
    @config
  end

  def default_cipher do
    cipher = Enum.find @config, fn({_cipher, opts}) ->
      opts[:default] == true
    end

    unless cipher do
      raise """
      Please specify a default cipher in your mix configuration. See `Cloak`'s
      documentation to find out how.
      """
    end

    cipher
  end
end
