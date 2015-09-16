defmodule Cloak.Cipher do
  @moduledoc """
  A behaviour for encryption/decryption modules.
  """

  use Behaviour

  @doc """
  Encrypt a value. Your function should include any information it will need for
  decryption with the output.
  """
  defcallback encrypt(any) :: String.t

  @doc """
  Decrypt a value.
  """
  defcallback decrypt(String.t) :: String.t

  @doc """
  Must return a string representing the default settings of your module as it is
  currently configured. 
  
  This will be used by `Cloak.version/0` to generate a unique tag, which can 
  then be stored on each database table row to track which encryption
  configuration it is currently encrypted with.

  See `Cloak.Model` for more details.
  """
  defcallback version :: String.t
end
