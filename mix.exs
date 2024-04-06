defmodule Cloak.Mixfile do
  use Mix.Project

  @source_url "https://github.com/danielberkompas/cloak"
  @version "1.1.4"

  def project do
    [
      app: :cloak,
      version: @version,
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
      {:castore, "~> 1.0", only: :test},
      {:ex_doc, ">= 0.0.0", only: [:dev, :docs]},
      {:inch_ex, "~> 2.0", only: :docs}
    ]
  end

  defp docs do
    [
      extras: [
        "CHANGELOG.md": [],
        "LICENSE.md": [title: "License"],
        "README.md": [title: "Overview"],
        "guides/how_to/install.md": [title: "Install Cloak"],
        "guides/how_to/generate_keys.md": [title: "Generate Encryption Keys"],
        "guides/upgrading/0.9.x_to_1.0.x.md": [title: "0.9.x to 1.0.x"],
        "guides/upgrading/0.8.x_to_0.9.x.md": [title: "0.8.x to 0.9.x"],
        "guides/upgrading/0.7.x_to_0.8.x.md": [title: "0.7.x to 0.8.x"],
        "guides/upgrading/0.6.x_to_0.7.x.md": [title: "0.6.x to 0.7.x"],
        "guides/cheatsheets/cheatsheet.cheatmd": [title: "Cheatsheet"]
      ],
      main: "readme",
      source_url: @source_url,
      source_ref: "v#{@version}",
      formatters: ["html"],
      extra_section: "GUIDES",
      groups_for_extras: [
        Cheatsheets: ~r/cheatsheets/,
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
      description: "Elixir encryption library",
      files: ["lib", "mix.exs", "README.md", "CHANGELOG.md", "LICENSE.md"],
      maintainers: ["Daniel Berkompas"],
      licenses: ["MIT"],
      links: %{
        "Changelog" => "https://hexdocs.pm/clock/changelog.html",
        "GitHub" => @source_url
      }
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]
end
