defmodule Cloak.ConfigTest do
  use ExUnit.Case, async: true

  describe "#all" do
    setup do
      modules =
        Cloak.Config.all()
        |> Enum.map(fn {key, _} -> key end)
        |> MapSet.new()

      {:ok, modules: modules}
    end

    test "it includes Cloak.AES.GCM", context do
      assert MapSet.member?(context[:modules], Cloak.AES.GCM)
    end

    test "it includes Cloak.AES.CTR", context do
      assert MapSet.member?(context[:modules], Cloak.AES.CTR)
    end

    test "it doesn't include :json_library", context do
      refute MapSet.member?(context[:modules], :json_library)
    end
  end
end
