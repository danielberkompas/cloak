# Installing Cloak

This guide will walk you through installing Cloak in your project.

### Add the Dependency

First, add `:cloak` to your dependencies in `mix.exs`:

    {:cloak, "~> 1.7.0-alpha.1"}

Run `mix deps.get` to fetch the dependency.

### Create a Vault

Next, create a `Cloak.Vault` for your project.

    defmodule MyApp.Vault do
      use Cloak.Vault, otp_app: :my_app
    end

Configure it as shown in the `Cloak.Vault` documentation, with at least one
active cipher. Note that the `:key` needs to be a binary, not base64 encoded.

    config :my_app, MyApp.Vault,
      ciphers: [
        default: {Cloak.Ciphers.AES.GCM, tag: "AES.GCM.V1", key: <<...>>}
      ]

If you want to fetch keys from system vars, you should use the `init/1` callback
to configure the vault instead:

    # Assumes that you have a CLOAK_KEY environment variable containing a key in
    # Base64 encoding.
    #
    # export CLOAK_KEY="A7x+qcFD9yeRfl3GohiOFZM5bNCdHNu27B0Ozv8X4dE="

    defmodule MyApp.Vault do
      use Cloak.Vault, otp_app: :my_app

      @impl Cloak.Vault
      def init(config) do
        config =
          Keyword.put(config, :ciphers, [
            default: {Cloak.Ciphers.AES.GCM, tag: "AES.GCM.V1", key: decode_env("CLOAK_KEY")}
          ])

        {:ok, config}
      end

      defp decode_env(var) do
        var
        |> System.get_env()
        |> Base.decode64!()
      end
    end

### Create Local Ecto Types

For each type of data you want to encrypt, define a local Ecto type like so.

    defmodule MyApp.Encrypted.Binary do
      use Cloak.Fields.Binary, vault: MyApp.Vault
    end

You can find a complete list of available types in the "MODULES" documentation.

### Create Your Schema

If you want to encrypt an existing schema, see the guide on [Encrypting
Existing Data](encrypt_existing_data.html).

If you're starting from scratch with a new `Ecto.Schema`, it's enough to
generate the migration with the correct fields, for example:

    create table(:users) do
      add :email, :binary
      add :email_hash, :binary # will be used for searching
      # ...

      timestamps()
    end

The schema module should look like this:

    defmodule MyApp.Accounts.User do
      use Ecto.Schema

      import Ecto.Changeset

      schema "users" do
        field :email, MyApp.Encrypted.Binary
        field :email_hash, Cloak.Fields.SHA256
        # ... other fields

        timestamps()
      end

      @doc false
      def changeset(struct, attrs \\ %{}) do
        struct
        |> cast(attrs, [:email])
        |> put_hashed_fields()
      end

      defp put_hashed_fields(changeset) do
        changeset
        |> put_change(:email_hash, get_field(changeset, :email))
      end
    end

This example also shows how you would make a given field queryable by
creating a mirrored `_hash` field. See `Cloak.Fields.SHA256` or
`Cloak.Fields.HMAC` for more details.

## Usage

Your encrypted fields will be transparently encrypted and decrypted as
data are loaded from the database.

    Repo.get(Accounts.User, 1)
    # => %Accounts.User{email: "test@example.com", email_hash: <<115, 6, 45, 135, 41, ...>>}

You can query by the mirrored `_hash` fields:

    Repo.get_by(Accounts.User, email_hash: "test@example.com")
    # => %Accounts.User{email: "test@example.com", ...}

And you're done! Cloak is successfully installed.