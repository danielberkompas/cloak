defmodule Cloak.Vault do
  @moduledoc """
  Encrypts and decrypts data, using a configured cipher.

  ## Configuration

  When used, the vault expects the `:otp_app` option. The `:otp_app` option
  should point to an OTP application that has the vault configuration.

  For example, the vault:

      defmodule MyApp.Vault do
        use Cloak.Vault, otp_app: :my_app
      end

  Could be configured with:

      config :my_app, MyApp.Vault,
        json_library: Poison,
        ciphers: [
          default: {Cloak.Cipher.AES.GCM, tag: "AES.GCM.V1", key: <<...>>}
        ]

  The configuration options are:

  ### `:json_library`

  Used to convert data types like lists and maps into binary so that they can
  be encrypted. (Default: `Poison`)

  ### `:ciphers`

  A `Keyword` list of `Cloak.Cipher` modules to use for encryption or
  decryption, in the following format:

      {label, {cipher_module, opts}}

  The `opts` are specific to each cipher module. Check their documentation
  for details. The following ciphers ship with Cloak:

  - `Cloak.Cipher.AES.GCM` (recommended) - AES encryption in Galois Counter Mode (GCM).
  - `Cloak.Cipher.AES.CTR` - AES encryption in CTR stream mode.

  **IMPORTANT: THE _FIRST_ CONFIGURED CIPHER IN THE LIST IS THE DEFAULT FOR
  ENCRYPTING ALL NEW DATA.** (Regardless of its label!) The other ciphers
  are, by default, used only for decryption. (This behavior can be overriden
  on a field-by-field basis, see below)

  ### Runtime Configuration

  Vaults can be configured at runtime using the `init/1` callback. This allows
  you to easily fetch values like environment variables in a reliable way.

  The configuration from the `:otp_app` is passed as the first argument to the
  callback, allowing you to append to or change it at will.

      defmodule MyApp.Vault do
        use Cloak.Vault, otp_app: :my_app

        @impl Cloak.Vault
        def init(config) do
          config =
            Keyword.put(config, :ciphers, [
              default: {Cloak.Cipher.AES.GCM, tag: "AES.GCM.V1", key: System.get_env("CLOAK_KEY")}
            ])

          {:ok, config}
        end
      end

  ### Configuring Ecto Types

  Once you have a configured vault, you can define `Ecto.Type` modules which
  use it for encryption/decryption.

      defmodule MyApp.EncryptedBinaryField do
        use Cloak.EncryptedBinaryField, vault: MyApp.Vault
      end

  You can also specify that a field uses a particular labeled cipher from
  your configuration:

      defmodule MyApp.EncryptedBinaryField do
        use Cloak.EncryptedBinaryField,
          vault: MyApp.Vault,
          cipher: :custom # corresponds to the `label` of the cipher
      end

  **The field will only use the specified cipher for encryption, not
  decryption.** It will decrypt stored data with whichever cipher originally
  generated it.

  The following Cloak field types are available:

  | Type            | Ecto Type             | Field                               |
  | --------------- | --------------------- | ----------------------------------- |
  | `String`        | `:string` / `:binary` | `Cloak.EncryptedBinaryField`        |
  | `Date`          | `:date`               | `Cloak.EncryptedDateField`          |
  | `DateTime`      | `:utc_datetime`       | `Cloak.EncryptedDateTimeField`      |
  | `Float`         | `:float`              | `Cloak.EncryptedFloatField`         |
  | `Integer`       | `:integer`            | `Cloak.EncryptedIntegerField`       |
  | `Map`           | `:map`                | `Cloak.EncryptedMapField`           |
  | `NaiveDateTime` | `:naive_datetime`     | `Cloak.EncryptedNaiveDateTimeField` |
  | `Time`          | `:time`               | `Cloak.EncryptedTimeField`          |
  | `[Integer]`     | `{:array, :integer}`  | `Cloak.EncryptedIntegerListField`   |
  | `[String]`      | `{:array, :string}`   | `Cloak.EncryptedStringListField`    |

  ## Usage

  ### Direct Usage

  You can use the vault directly by calling its functions.

      MyApp.Vault.encrypt("plaintext")
      # => {:ok, <<...>>}

      MyApp.Vault.decrypt(ciphertext)
      # => {:ok, "plaintext"}

  ### With Schemas

  Once you have configured your types, you can use them in your `Ecto.Schema`s.
  Be sure to first create the fields with the `:binary` type in your migration:

      # in your migration
      create table(:users) do
        add :email, :binary
        add :encryption_version, :binary
      end

  Then, use the custom `Ecto.Type` you defined, as in this example:

      defmodule MyApp.Accounts.User do
        use Ecto.Schema

        import Ecto.Changeset

        schema "users" do
          field :email, MyApp.EncryptedBinaryField
          field :encryption_version, :binary
        end

        def changeset(struct, attrs \\\\ %{}) do
          struct
          |> cast(attrs, [:email])
          |> put_change(:encryption_version, MyApp.Vault.version())
        end
      end

  In this case, the `:email` field will now be transparently encrypted when
  written to the database and decrypted when loaded out of the database.

  The `:encryption_version` field is important for migrating data when you
  rotate keys. See `Mix.Tasks.Cloak.Migrate` for more details.

  ### Querying Encrypted Data

  By design, Cloak ciphers produce unique ciphertext each time, even if the
  value remains the same. As a result, you cannot query on an encrypted
  schema field directly.

  However, you can create a mirror of a encrypted field which contains a
  predictable hashed value. This allows you to query for exact matches.

  In your migration, create a `[field_name]_hash` field:

      change table(:users) do
        add :email_hash, :binary
      end

  Then, in your schema, use one of Cloak's provided hash types, which are:

  | Type      | Ecto Type              | Field               |
  | --------- | ---------------------- | ------------------- |
  | `String`  | `:string` / `:binary`  | `Cloak.SHA256Field` |

  In this example, we'll use `Cloak.SHA256Field`:

      schema "users" do
        field :email, MyApp.EncryptedBinaryField
        field :email_hash, Cloak.SHA256Field
        field :encryption_version, :binary
      end

  Finally, in your `changeset/2` function, ensure that the `_hash` field
  is updated every time the main field is changed:

      def changeset(struct, attrs \\\\ %{}) do
        struct
        |> cast(attrs, [:email])
        |> put_hashed_fields()
        |> put_change(:encryption_version, MyApp.Vault.version())
      end

      defp put_hashed_fields(changeset) do
        changeset
        |> put_change(:email_hash, get_field(changeset, :email))
      end

  Now, you can query by the `_hash` field anywhere you might have previously
  queried by the main field.

      Repo.get_by(MyApp.Accounts.User, email_hash: "test@example.com")
      # => %MyApp.Accounts.User{
      #      email: "test@example.com",
      #      email_hash:
      #        <<151, 61, 254, 70, 62, 200, 87, 133, 245, 249, 90, 245, 186, 57,
      #        6, 238, 219, 45, 147, 28, 36, 230, 152, 36, 168, 158, 166, 93,
      #        186, 78, 129, 59>>,
      #      encryption_version: "AES.GCM.V1"
      #    }

  ### Rotating Keys

  See `Mix.Tasks.Cloak.Migrate` for instructions on how to rotate keys.
  """

  @doc """
  Accepts configuration from the vault's `:otp_app`, and returns updated
  configuration. Useful for changing configuration based on the runtime
  environment.

  ## Example

      def init(config) do
        config =
          Keyword.put(config, :ciphers, [
            default: {Cloak.Cipher.AES.GCM, tag: "AES.GCM.V1", key: System.get_env("CLOAK_KEY")}
          ])

        {:ok, config}
      end
  """
  @callback init(config :: Keyword.t()) :: {:ok, Keyword.t()} | :error

  @doc """
  Encrypts a binary using the first configured cipher in the vault's
  configured `:ciphers` list.
  """
  @callback encrypt(plaintext :: binary) :: {:ok, binary} | :error

  @doc """
  Encrypts a binary using the vault's configured cipher with the
  corresponding label.
  """
  @callback encrypt(plaintext :: binary, label :: atom) :: {:ok, binary} | :error

  @doc """
  Decrypts a binary with the configured cipher that generated the binary.
  Automatically detects which cipher to use, based on the ciphertext.
  """
  @callback decrypt(ciphertext :: binary) :: {:ok, String.t()} | :error

  @doc """
  Returns the version of the first configured cipher in the vault's
  configured `:ciphers` list, as this is the default.

  This is used for key rotation. See `Mix.Tasks.Cloak.Migrate`.
  """
  @callback version :: binary

  @doc """
  Returns the version of the vault's configured cipher with the
  corresponding label.
  """
  @callback version(label :: atom) :: binary

  @doc false
  defmacro __using__(opts) do
    otp_app = Keyword.fetch!(opts, :otp_app)

    quote location: :keep do
      @behaviour Cloak.Vault

      @impl Cloak.Vault
      def init(config) do
        {:ok, config}
      end

      @impl Cloak.Vault
      def encrypt(plaintext) do
        Cloak.Vault.encrypt(build_config(), plaintext)
      end

      @impl Cloak.Vault
      def encrypt(plaintext, label) do
        Cloak.Vault.encrypt(build_config(), plaintext, label)
      end

      @impl Cloak.Vault
      def decrypt(ciphertext) do
        Cloak.Vault.decrypt(build_config(), ciphertext)
      end

      @impl Cloak.Vault
      def version do
        Cloak.Vault.version(build_config())
      end

      @impl Cloak.Vault
      def version(label) do
        Cloak.Vault.version(build_config(), label)
      end

      defp build_config do
        Cloak.Vault.build_config(__MODULE__, unquote(otp_app))
      end

      defoverridable init: 1, encrypt: 1, decrypt: 1
    end
  end

  @doc false
  def encrypt(config, plaintext) do
    [{_label, {module, opts}} | _ciphers] = config[:ciphers]
    module.encrypt(plaintext, opts)
  end

  @doc false
  def encrypt(config, plaintext, label) do
    {module, opts} = config[:ciphers][label]
    module.encrypt(plaintext, opts)
  end

  @doc false
  def decrypt(config, ciphertext) do
    {_label, {module, opts}} =
      Enum.find(config[:ciphers], fn {_label, {module, opts}} ->
        module.can_decrypt?(ciphertext, opts)
      end)

    module.decrypt(ciphertext, opts)
  end

  @doc false
  def version(config) do
    [{_label, {module, opts}} | _] = config[:ciphers]
    module.version(opts)
  end

  @doc false
  def version(config, label) do
    {module, opts} = config[:ciphers][label]
    module.version(opts)
  end

  @doc false
  def build_config(vault, otp_app) do
    {:ok, config} =
      otp_app
      |> Application.get_env(vault, [])
      |> vault.init()

    config
  end
end
