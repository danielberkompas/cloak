import Config

config :cloak, Cloak.TestVault,
  json_library: Jason,
  ciphers: [
    default:
      {Cloak.Ciphers.AES.GCM,
       tag: "AES.GCM.V1",
       key: Base.decode64!("3Jnb0hZiHIzHTOih7t2cTEPEpY98Tu1wvQkPfq/XwqE="),
       iv_length: 12},
    secondary:
      {Cloak.Ciphers.AES.CTR,
       tag: "AES.CTR.V1", key: Base.decode64!("o5IzV8xlunc0m0/8HNHzh+3MCBBvYZa0mv4CsZic5qI=")}
  ]

config :logger, level: :warn
