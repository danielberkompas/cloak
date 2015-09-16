defmodule Cloak.Cipher do
  use Behaviour

  defmacro __using__(_) do
    quote do
      @behaviour unquote(__MODULE__)
    end
  end

  defcallback encrypt(any) :: String.t
  defcallback decrypt(String.t) :: String.t
  defcallback version
end
