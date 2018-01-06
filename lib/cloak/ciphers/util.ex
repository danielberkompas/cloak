defmodule Cloak.Ciphers.Util do
  @moduledoc false

  @spec config(module) :: Keyword.t()
  def config(cipher_module) do
    Application.get_env(:cloak, cipher_module)
  end

  @spec config(module, String.t() | nil) :: map | nil
  def config(cipher_module, tag) do
    cipher_module
    |> keys()
    |> Enum.find(fn key -> key.tag == tag end)
  end

  @spec default_key(module) :: map
  def default_key(cipher_module) do
    cipher_module
    |> keys()
    |> Enum.find(fn key -> key.default end)
  end

  @spec keys(module) :: [map]
  defp keys(cipher_module) do
    cipher_module
    |> config()
    |> Keyword.get(:keys)
  end

  @spec key_value(map) :: String.t() | no_return
  def key_value(key_config) do
    case key_config.key do
      {:system, env_var} ->
        env_var
        |> System.get_env()
        |> validate_key!(env_var)
        |> decode_key!(env_var)

      {:app_env, otp_app, env_var} ->
        otp_app
        |> Application.get_env(env_var)
        |> validate_key!(env_var)

      _ ->
        key_config.key
    end
  end

  @spec decode_key!(String.t(), String.t()) :: String.t() | no_return
  defp decode_key!(key, env_var) do
    case Base.decode64(key) do
      {:ok, decoded_key} -> decoded_key
      :error -> raise "Expect env variable #{env_var} to be a valid base64 string."
    end
  end

  @spec validate_key!(String.t() | nil, String.t() | atom) :: String.t() | no_return
  defp validate_key!(key, env_var) when key in [nil, ""] do
    raise "Expect env variable #{env_var} to define a key, but is empty."
  end

  defp validate_key!(key, _), do: key
end
