defmodule Cloak.Util do

  def config(module) do
    Application.get_env(:cloak, module)
  end

  def config(module, tag) do
    module
    |> config()
    |> Keyword.get(:keys)
    |> Enum.find(fn(key) -> key.tag == tag end)
  end

  def default_key(module) do
    module
    |> config()
    |> Keyword.get(:keys)
    |> Enum.find(fn(key) -> key.default end)
  end

  def key_value(key_config) do
    case key_config.key do
      {:system, env_var} ->
        env_var
        |> System.get_env()
        |> validate_key!(env_var)
        |> decode_key(env_var)

      {:app_env, otp_app, env_var} ->
        otp_app
        |> Application.get_env(env_var)
        |> validate_key!(env_var)

      _ ->
        key_config.key
    end
  end

  defp decode_key(key, env_var) do
    case Base.decode64(key) do
      {:ok, decoded_key} -> decoded_key
      :error -> raise "Expect env variable #{env_var} to be a valid base64 string."
    end
  end

  defp validate_key!(key, env_var) when key in [nil, ""] do
    raise "Expect env variable #{env_var} to define a key, but is empty."
  end
  defp validate_key!(key, _), do: key

end
