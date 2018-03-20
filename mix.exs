defmodule Cloak.Mixfile do
  use Mix.Project

  def project do
    [
      app: :cloak,
      version: "0.7.0",
      elixir: "~> 1.0",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      source_url: "https://github.com/danielberkompas/cloak",
      description: "Encrypted fields for Ecto.",
      package: package(),
      deps: deps(),
      docs: docs(),
      elixirc_paths: elixirc_paths(Mix.env())
    ]
  end

  def application do
    [applications: [:logger]]
  end

  defp deps do
    [
      {:ecto, ">= 1.0.0"},
      {:poison, ">= 1.5.0", optional: true},
      {:ex_doc, ">= 0.0.0", only: [:dev, :docs]},
      {:inch_ex, ">= 0.0.0", only: :docs}
    ]
  end

  defp docs do
    [
      readme: "README.md",
      main: Cloak,
      extras: [
        "guides/how_to/encrypt_existing_data.md": [title: "Encrypt Existing Data"],
        "guides/how_to/rotate_keys.md": [title: "Rotate Keys"],
        "guides/upgrading/0.6.x_to_0.7.x.md": [title: "0.6.x to 0.7.x"]
      ],
      groups_for_extras: [
        "How To": ~r/how_to/,
        Upgrading: ~r/upgrading/
      ],
      groups_for_modules: [
        Behaviours: [
          Cloak.Cipher,
          Cloak.Vault
        ],
        Ciphers: ~r/Cipher.AES/,
        "Deprecated Ciphers": ~r/Cipher.Deprecated/,
        "Ecto Types": ~r/Field/
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
