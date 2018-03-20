defmodule Cloak.Config do
  @moduledoc false

  @spec json_library :: module
  def json_library do
    Application.get_env(:cloak, :json_library, Poison)
  end
end
