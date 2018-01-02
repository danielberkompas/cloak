use Mix.Config

config :cloak, Cloak.AES.CTR,
  tag: "AES",
  default: true,
  keys: [
    %{tag: <<1>>, key: :base64.decode("3Jnb0hZiHIzHTOih7t2cTEPEpY98Tu1wvQkPfq/XwqE="), default: true},
    %{tag: <<2>>, key: :base64.decode("iutsyenD9K2psbQNIvdf/UTBYrFH1ONJlQUpQ6nRoAw="), default: false},
    %{tag: <<3>>, key: {:system, "CLOAK_THIRD_KEY"}, default: false},
    %{tag: <<4>>, key: {:app_env, :testapp, :encryption_key}, default: false}
  ]

config :cloak, Cloak.AES.GCM,
  tag: "GCM",
  default: false,
  keys: [
    %{tag: <<1>>, key: :base64.decode("3Jnb0hZiHIzHTOih7t2cTEPEpY98Tu1wvQkPfq/XwqE="), default: true},
    %{tag: <<2>>, key: :base64.decode("iutsyenD9K2psbQNIvdf/UTBYrFH1ONJlQUpQ6nRoAw="), default: false},
    %{tag: <<3>>, key: {:system, "CLOAK_THIRD_KEY"}, default: false},
    %{tag: <<4>>, key: {:app_env, :testapp, :encryption_key}, default: false}
  ]
