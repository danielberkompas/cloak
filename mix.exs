defmodule Cloak.Mixfile do
  use Mix.Project

  def project do
    [app: :cloak,
     version: "0.3.3",
     elixir: "~> 1.0",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     source_url: "https://github.com/danielberkompas/cloak",
     description: "Encrypted fields for Ecto.",
     package: package(),
     deps: deps(),
     docs: docs()]
  end

  def application do
    [applications: [:poison, :logger]]
  end

  defp deps do
    [{:poison, ">= 1.5.0"},
     {:ecto, ">= 1.0.0"},
     {:ex_doc, "~> 0.11", only: [:dev, :docs]},
     {:inch_ex, ">= 0.0.0", only: :docs}
   ]
  end

  defp docs do
    [
      readme: "README.md",
      main: Cloak
    ]
  end

  defp package do
    [
      files: ["lib", "mix.exs", "README.md", "CHANGELOG.md", "LICENSE"],
      maintainers: ["Daniel Berkompas"],
      licenses: ["MIT"],
      links: %{
        "Github" => "https://github.com/danielberkompas/cloak"
      }
    ]
  end
end
