defmodule Cloak.Config do
  @config Application.get_all_env(:cloak)

  def all do
    @config
  end

  def default_cipher do
    Enum.find @config, fn({_cipher, opts}) ->
      opts[:default] == true
    end
  end
end
