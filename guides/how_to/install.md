# Installing Cloak

This guide will walk you through installing Cloak in your project.

### Add the Dependency

First, add `:cloak` to your dependencies in `mix.exs`:

    {:cloak, "1.0.2"}

Run `mix deps.get` to fetch the dependency.

### Generate a Key

You'll need a secret key for encryption. This is easy to generate in the
IEx console.

    $ iex
    iex> 32 |> :crypto.strong_rand_bytes() |> Base.encode64()
    "aJ7HcM24BcyiwsAvRsa3EG3jcvaFWooyQJ+91OO7bRU="

This will generate a relatively strong encryption 256-bit encryption
key encoded with Base64.

### Create a Vault

Next, create a `Cloak.Vault` for your project.

    defmodule MyApp.Vault do
      use Cloak.Vault, otp_app: :my_app
    end

Configure it as shown in the `Cloak.Vault` documentation, with at least one
active cipher. Note that the `:key` needs to be decoded from Base64 encoding into
its raw binary form.

    config :my_app, MyApp.Vault,
      ciphers: [
        default: {
          Cloak.Ciphers.AES.GCM, 
          tag: "AES.GCM.V1", 
          key: Base.decode64!("your-key-here"),
          # In AES.GCM, it is important to specify 12-byte IV length for
          # interoperability with other encryption software. See this GitHub
          # issue for more details:
          # https://github.com/danielberkompas/cloak/issues/93
          # 
          # In Cloak 2.0, this will be the default iv length for AES.GCM.
          iv_length: 12
        }
      ]

If you want to fetch keys from system vars, you should use the `init/1` callback
to configure the vault instead:

    # Assumes that you have a CLOAK_KEY environment variable containing a key in
    # Base64 encoding.
    #
    # export CLOAK_KEY="A7x+qcFD9yeRfl3GohiOFZM5bNCdHNu27B0Ozv8X4dE="

    defmodule MyApp.Vault do
      use Cloak.Vault, otp_app: :my_app

      @impl GenServer
      def init(config) do
        config =
          Keyword.put(config, :ciphers, [
            default: {
              Cloak.Ciphers.AES.GCM, 
              tag: "AES.GCM.V1", 
              key: decode_env!("CLOAK_KEY"),
              iv_length: 12
            }
          ])

        {:ok, config}
      end

      defp decode_env!(var) do
        var
        |> System.get_env()
        |> Base.decode64!()
      end
    end

Finally, add your vault to your supervision tree.

    children = [
      MyApp.Vault
    ]

## Usage

You can now encrypt and decrypt values using your Vault.

    {:ok, ciphertext} = MyApp.Vault.encrypt("plaintext") 
    # => {:ok, <<1, 10, 65, 69, 83, 46, 71, 67, 77, 46, 86, 49, 93, 140, 255, 234,
    1, 195, 125, 112, 121, 186, 169, 185, 129, 122, 237, 161, 160, 24, 166,
    48, 224, 230, 53, 194, 251, 175, 215, 10, 186, 130, 61, 230, 176, 102,
    213, 209, ...>>}

    MyApp.Vault.decrypt(ciphertext)
    {:ok, "plaintext"}

By default, the first configured key will be used. You can use a specific key
to use by referencing its label:

    MyApp.Vault.encrypt("plaintext", :default)

Decryption will use the metadata embedded in the ciphertext to decide which
configured key to use.

## Usage with Ecto

If you want to use Cloak to automatically encrypt and decrypt fields in your
`Ecto` schemas, see [`cloak_ecto`](https://hex.pm/packages/cloak_ecto).