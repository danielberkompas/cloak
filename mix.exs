defmodule Cloak.Mixfile do
  use Mix.Project

  def project do
    [
      app: :cloak,
      version: "1.1.2",
      elixir: "~> 1.0",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test
      ],
      source_url: "https://github.com/danielberkompas/cloak",
      description: "Elixir encryption library",
      package: package(),
      deps: deps(),
      docs: docs(),
      elixirc_paths: elixirc_paths(Mix.env())
    ]
  end

  def application do
    [extra_applications: [:logger, :crypto]]
  end

  defp deps do
    [
      {:jason, "~> 1.0", optional: true},
      {:excoveralls, "~> 0.14", only: :test},
      {:ex_doc, ">= 0.0.0", only: [:dev, :docs]},
      {:inch_ex, "~> 2.0", only: :docs}
    ]
  end

  defp docs do
    [
      main: "readme",
      extras: [
        "README.md",
        "guides/how_to/install.md": [title: "Install Cloak"],
        "guides/how_to/generate_keys.md": [title: "Generate Encryption Keys"],
        "guides/upgrading/0.9.x_to_1.0.x.md": [title: "0.9.x to 1.0.x"],
        "guides/upgrading/0.8.x_to_0.9.x.md": [title: "0.8.x to 0.9.x"],
        "guides/upgrading/0.7.x_to_0.8.x.md": [title: "0.7.x to 0.8.x"],
        "guides/upgrading/0.6.x_to_0.7.x.md": [title: "0.6.x to 0.7.x"]
      ],
      extra_section: "GUIDES",
      groups_for_extras: [
        "How To": ~r/how_to/,
        Upgrading: ~r/upgrading/
      ],
      groups_for_modules: [
        Behaviours: [
          Cloak.Cipher,
          Cloak.Vault
        ],
        Ciphers: ~r/Ciphers.AES/,
        "Deprecated Ciphers": ~r/Ciphers.Deprecated/
      ]
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

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]
end
