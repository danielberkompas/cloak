use Mix.Config

config :cloak, Cloak.AES.CTR,
  tag: "AES",
  default: true,
  keys: [
    %{tag: <<1>>, key: "...", default: true},
    %{tag: <<2>>, key: "...", default: false}
  ]
