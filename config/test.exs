use Mix.Config

config :cloak, json_library: Poison

config :cloak, Cloak.TestVault,
  ciphers: [
    default:
      {Cloak.Cipher.AES.GCM,
       tag: "AES.GCM.V1", key: :base64.decode("3Jnb0hZiHIzHTOih7t2cTEPEpY98Tu1wvQkPfq/XwqE=")}
  ]
