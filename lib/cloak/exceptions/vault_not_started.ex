defmodule Cloak.VaultNotStarted do
  @moduledoc """
  This exception indicates that your vault process hasn't been started yet. Before 
  calling any vault functions, you must either:

  #### 1. Call `start_link/0` on your vault module

      MyApp.Vault.start_link()

  #### 2. Ensure your application is started
  If your vault module has been added to your application supervision tree, make
  sure your application is running before calling any vault functions.

      Application.ensure_all_started(:my_app)

  """
  defexception [:message, :vault]

  @doc false
  def exception(table_name) do
    vault = infer_vault_name(table_name)

    %__MODULE__{
      message: """
      #{vault}.Config ETS table was not found! 

      This indicates that your vault process is not running. Ensure that it is 
      running before calling this function.

      The simplest way to do that is to call `start_link/0`:

         #{vault}.start_link()

      If your vault has been added to your application's supervision tree, 
      ensure that your app has been started before calling any vault functions.

         Application.ensure_all_started(:my_app)
      """,
      vault: vault
    }
  end

  defp infer_vault_name(table_name) do
    table_name
    |> to_string()
    |> String.replace(".Config", "")
    |> String.replace("Elixir.", "")
    |> String.to_atom()
  end
end
