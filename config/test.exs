use Mix.Config

config :cloak, json_library: Poison

config :cloak, Cloak.TestVault,
  ciphers: [
    default:
      {Cloak.Ciphers.AES.GCM,
       tag: "AES.GCM.V1", key: Base.decode64!("3Jnb0hZiHIzHTOih7t2cTEPEpY98Tu1wvQkPfq/XwqE=")},
    secondary:
      {Cloak.Ciphers.AES.CTR,
       tag: "AES.CTR.V1", key: Base.decode64!("o5IzV8xlunc0m0/8HNHzh+3MCBBvYZa0mv4CsZic5qI=")}
  ]

config :logger, level: :warn

config :cloak, ecto_repos: [Cloak.TestRepo]

config :cloak, Cloak.TestRepo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "cloak_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox,
  priv: "test/support/"
