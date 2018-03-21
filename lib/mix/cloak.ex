defmodule Mix.Cloak do
  @moduledoc false
  # Helpers for building Mix tasks for Cloak

  # %{ app => %{repo: repo, schemas: schemas}}
  def parse_config(args) do
    {opts, _, _} = OptionParser.parse(args, aliases: [s: :schema, r: :repo])

    opts
    |> Enum.into(%{})
    |> do_parse_config()
  end

  defp do_parse_config(%{repo: repo, schema: schema}) do
    %{current_app() => %{repo: to_module(repo), schemas: [to_module(schema)]}}
  end

  defp do_parse_config(_argv) do
    get_apps()
    |> Enum.map(&get_app_config/1)
    |> Enum.into(%{})
    |> validate_config!()
  end

  defp get_apps do
    apps = Mix.Project.apps_paths()

    if apps do
      Map.keys(apps)
    else
      [current_app()]
    end
  end

  defp get_app_config(app) do
    {app,
     %{
       repo: Application.get_env(app, :cloak_repo),
       schemas: Application.get_env(app, :cloak_schemas)
     }}
  end

  defp current_app do
    Mix.Project.config()[:app]
  end

  defp validate_config!(config) do
    invalid_configs = Enum.filter(config, &(!valid?(&1)))

    unless length(invalid_configs) == 0 do
      apps = Keyword.keys(invalid_configs)

      raise Mix.Error, """
      warning: no configured Ecto repos or schemas found in any of the apps: #{inspect(apps)}

      You can avoid this by passing the -r and -s flags or by setting the repo and schemas
      in your config/config.exs:

          config #{inspect(hd(apps))},
            cloak_repo: ...,
            cloak_schemas: [...]
      """
    end

    config
  end

  defp valid?({_app, %{repo: repo, schemas: [schema | _]}})
       when is_atom(repo) and is_atom(schema),
       do: true

  defp valid?(_config), do: false

  defp to_module(name) do
    String.to_existing_atom("Elixir." <> name)
  end
end
