defmodule Cloak.Vault do
  @moduledoc """
  Encrypts and decrypts data, using a configured cipher.

  ## Configuration

  Vaults require the `:otp_app` option. The `:otp_app` option
  should point to an OTP application that has the vault configuration.

  For example, the vault:

      defmodule MyApp.Vault do
        use Cloak.Vault, otp_app: :my_app
      end

  Could be configured with:

      config :my_app, MyApp.Vault,
        json_library: Poison,
        ciphers: [
          default: {Cloak.Ciphers.AES.GCM, tag: "AES.GCM.V1", key: <<...>>}
        ]

  The configuration options are:

  - `:json_library`: Used to convert data types like lists and maps into
    binary so that they can be encrypted. (Default: `Poison`)

  - :ciphers: a list of `Cloak.Cipher` modules the following format:

          {:label, {CipherModule, opts}}

    **The first configured cipher in the list is the default for encrypting
    all new data, regardless of its label.** This behaviour can be overridden
    on a field-by-field basis.

    The `opts` are specific to each cipher module. Check their
    codumentation for what each cipher requires.

      - `Cloak.Ciphers.AES.GCM`
      - `Cloak.Ciphers.AES.CTR`

  ### Runtime Configuration

  Because Vaults are GenServers, they can be configured at runtime using the
  `init/1` callback. This allows you to easily fetch values like environment
  variables in a reliable way.

  The configuration from the `:otp_app` is passed as the first argument to the
  callback, allowing you to append to or change it at will.

      defmodule MyApp.Vault do
        use Cloak.Vault, otp_app: :my_app

        @impl GenServer
        def init(config) do
          config =
            Keyword.put(config, :ciphers, [
              default: {Cloak.Ciphers.AES.GCM, tag: "AES.GCM.V1", key: decode_env!("CLOAK_KEY")}
            ])

          {:ok, config}
        end

        defp decode_env!(var) do
          var
          |> System.get_env()
          |> Base.decode64!()
        end
      end

  You can also pass configuration to vaults via `start_link/1`:

      MyApp.Vault.start_link(ciphers: [
        default: {Cloak.Ciphers.AES.GCM, tag: "AES.GCM.V1", key: key}
      ])

  ### Configuring Ecto Types

  Once you have a configured vault, you can define `Ecto.Type` modules which
  use it for encryption/decryption.

      defmodule MyApp.Encrypted.Binary do
        use Cloak.Fields.Binary, vault: MyApp.Vault
      end

  You can also specify that a field uses a particular labeled cipher from
  your configuration:

      defmodule MyApp.Encrypted.Binary do
        use Cloak.Fields.Binary,
          vault: MyApp.Vault,
          cipher: :custom # corresponds to the `label` of the cipher
      end

  **The field will only use the specified cipher for encryption, not
  decryption.** It will decrypt stored data with whichever cipher originally
  generated it.

  The following Cloak field types are available:

  | Elixir Type     | Ecto Type             | Cloak Type                   |
  | --------------- | --------------------- | ---------------------------- |
  | `String`        | `:string` / `:binary` | `Cloak.Fields.Binary`        |
  | `Date`          | `:date`               | `Cloak.Fields.Date`          |
  | `DateTime`      | `:utc_datetime`       | `Cloak.Fields.DateTime`      |
  | `Float`         | `:float`              | `Cloak.Fields.Float`         |
  | `Integer`       | `:integer`            | `Cloak.Fields.Integer`       |
  | `Map`           | `:map`                | `Cloak.Fields.Map`           |
  | `NaiveDateTime` | `:naive_datetime`     | `Cloak.Fields.NaiveDateTime` |
  | `Time`          | `:time`               | `Cloak.Fields.Time`          |
  | `[Integer]`     | `{:array, :integer}`  | `Cloak.Fields.IntegerList`   |
  | `[String]`      | `{:array, :string}`   | `Cloak.Fields.StringList`    |

  ## Supervision

  Because Vaults are `GenServer`s, you'll need to add your vault to your
  supervision tree in `application.ex` or whichever supervisor you prefer.

      children = [
        MyApp.Vault
      ]

  If you want to pass in configuration values at runtime, you can do so:

      children = [
        {MyApp.Vault, ciphers: [...]}
      ]

  ## Usage

  ### Direct Usage

  You can use the vault directly by calling its functions.

      MyApp.Vault.encrypt("plaintext")
      # => {:ok, <<...>>}

      MyApp.Vault.decrypt(ciphertext)
      # => {:ok, "plaintext"}

  See the documented callbacks below for the functions you can call.

  ### With Schemas

  Once you have configured your types, you can use them in your `Ecto.Schema`s.
  Be sure to first create the fields with the `:binary` type in your migration:

      # in your migration
      create table(:users) do
        add :email, :binary
      end

  Then, use the custom `Ecto.Type` you defined, as in this example:

      defmodule MyApp.Accounts.User do
        use Ecto.Schema

        import Ecto.Changeset

        schema "users" do
          field :email, MyApp.Encrypted.Binary
        end

        def changeset(struct, attrs \\\\ %{}) do
          struct
          |> cast(attrs, [:email])
        end
      end

  In this case, the `:email` field will now be transparently encrypted when
  written to the database and decrypted when loaded out of the database.

  ### Querying Encrypted Data

  By design, Cloak ciphers produce unique ciphertext each time, even if the
  value remains the same. As a result, you cannot query on an encrypted
  schema field directly.

  However, you can create a mirror of a encrypted field which contains a
  predictable hashed value. This allows you to query for exact matches.

  In your migration, create a `[field_name]_hash` field:

      alter table(:users) do
        add :email_hash, :binary
      end

  Then, in your schema, use one of Cloak's provided hash types, which are:

  | Type      | Ecto Type              | Field                 |
  | --------- | ---------------------- | --------------------- |
  | `String`  | `:string` / `:binary`  | `Cloak.Fields.SHA256` |
  | `String`  | `:string` / `:binary`  | `Cloak.Fields.HMAC`   |
  | `String`  | `:string` / `:binary`  | `Cloak.Fields.PBKDF2` |

  In this example, we'll use `Cloak.Fields.SHA256`:

      schema "users" do
        field :email, MyApp.Encrypted.Binary
        field :email_hash, Cloak.Fields.SHA256
      end

  Finally, in your `changeset/2` function, ensure that the `_hash` field
  is updated every time the main field is changed:

      def changeset(struct, attrs \\\\ %{}) do
        struct
        |> cast(attrs, [:email])
        |> put_hashed_fields()
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
      #        186, 78, 129, 59>>
      #    }

  ### Rotating Keys

  See `Mix.Tasks.Cloak.Migrate` for instructions on how to rotate keys.

  ### Performance Notes

  Vaults are not bottlenecks. They simply store configuration in ETS
  tables. All encryption and decryption is performed in your local
  process, reading configuration from the vault's ETS table.
  """

  @type plaintext :: binary
  @type ciphertext :: binary
  @type label :: atom

  @doc """
  Encrypts a binary using the first configured cipher in the vault's
  configured `:ciphers` list.
  """
  @callback encrypt(plaintext) :: {:ok, ciphertext} | {:error, Exception.t()}

  @doc """
  Like `encrypt/1`, but raises any errors.
  """
  @callback encrypt!(plaintext) :: ciphertext | no_return

  @doc """
  Encrypts a binary using the vault's configured cipher with the
  corresponding label.
  """
  @callback encrypt(plaintext, label) :: {:ok, ciphertext} | {:error, Exception.t()}

  @doc """
  Like `encrypt/2`, but raises any errors.
  """
  @callback encrypt!(plaintext, label) :: ciphertext | no_return

  @doc """
  Decrypts a binary with the configured cipher that generated the binary.
  Automatically detects which cipher to use, based on the ciphertext.
  """
  @callback decrypt(ciphertext) :: {:ok, plaintext} | {:error, Exception.t()}

  @doc """
  Like `decrypt/1`, but raises any errors.
  """
  @callback decrypt!(ciphertext) :: plaintext | no_return

  @doc """
  The JSON library the vault uses to convert maps and lists into
  JSON binaries before encryption.
  """
  @callback json_library :: module

  defmacro __using__(opts) do
    otp_app = Keyword.fetch!(opts, :otp_app)

    quote location: :keep do
      use GenServer

      @behaviour Cloak.Vault
      @otp_app unquote(otp_app)
      @table_name :"#{__MODULE__}.Config"

      ###
      # GenServer
      ###

      def start_link(config \\ []) do
        # Merge passed in configuration with otp_app configuration
        app_config = Application.get_env(@otp_app, __MODULE__, [])
        config = Keyword.merge(app_config, config)

        # Start the server
        {:ok, pid} = GenServer.start_link(__MODULE__, config, name: __MODULE__)

        # Ensure that the configuration is saved
        GenServer.call(pid, :save_config, 10_000)

        # Return the pid
        {:ok, pid}
      end

      # Users can override init/1 to customize the configuration
      # of the vault during startup
      @impl GenServer
      def init(config) do
        {:ok, config}
      end

      # Cache the results of the `init` configuration callback in
      # the application configuration for this Vault.
      @impl GenServer
      def handle_call(:save_config, _from, config) do
        Cloak.Vault.save_config(@table_name, config)
        {:reply, :ok, config}
      end

      # If a hot upgrade occurs, rerun the `init` callback to
      # refresh the configuration in case it changed
      @impl GenServer
      def code_change(_vsn, config, _extra) do
        config = init(config)
        Cloak.Vault.save_config(@table_name, config)
        {:ok, config}
      end

      ###
      # Encrypt/Decrypt functions
      ###

      @impl Cloak.Vault
      def encrypt(plaintext) do
        @table_name
        |> Cloak.Vault.read_config()
        |> Cloak.Vault.encrypt(plaintext)
      end

      @impl Cloak.Vault
      def encrypt!(plaintext) do
        @table_name
        |> Cloak.Vault.read_config()
        |> Cloak.Vault.encrypt!(plaintext)
      end

      @impl Cloak.Vault
      def encrypt(plaintext, label) do
        @table_name
        |> Cloak.Vault.read_config()
        |> Cloak.Vault.encrypt(plaintext, label)
      end

      @impl Cloak.Vault
      def encrypt!(plaintext, label) do
        @table_name
        |> Cloak.Vault.read_config()
        |> Cloak.Vault.encrypt!(plaintext, label)
      end

      @impl Cloak.Vault
      def decrypt(ciphertext) do
        @table_name
        |> Cloak.Vault.read_config()
        |> Cloak.Vault.decrypt(ciphertext)
      end

      @impl Cloak.Vault
      def decrypt!(ciphertext) do
        @table_name
        |> Cloak.Vault.read_config()
        |> Cloak.Vault.decrypt!(ciphertext)
      end

      @impl Cloak.Vault
      def json_library do
        @table_name
        |> Cloak.Vault.read_config()
        |> Keyword.get(:json_library, Poison)
      end

      defoverridable(Module.definitions_in(__MODULE__))
    end
  end

  @doc false
  def save_config(table_name, config) do
    if :ets.info(table_name) == :undefined do
      :ets.new(table_name, [:named_table, :protected])
    end

    :ets.insert(table_name, {:config, config})
  end

  @doc false
  def read_config(table_name) do
    case :ets.lookup(table_name, :config) do
      [{:config, config} | _] ->
        config

      _ ->
        :error
    end
  end

  @doc false
  def encrypt(config, plaintext) do
    with [{_label, {module, opts}} | _ciphers] <- config[:ciphers] do
      module.encrypt(plaintext, opts)
    else
      _ ->
        {:error, Cloak.InvalidConfig.exception("could not encrypt due to missing configuration")}
    end
  end

  @doc false
  def encrypt!(config, plaintext) do
    case encrypt(config, plaintext) do
      {:ok, ciphertext} ->
        ciphertext

      {:error, error} ->
        raise error
    end
  end

  @doc false
  def encrypt(config, plaintext, label) do
    case config[:ciphers][label] do
      nil ->
        {:error, Cloak.MissingCipher.exception(vault: config[:vault], label: label)}

      {module, opts} ->
        module.encrypt(plaintext, opts)
    end
  end

  @doc false
  def encrypt!(config, plaintext, label) do
    case encrypt(config, plaintext, label) do
      {:ok, ciphertext} ->
        ciphertext

      {:error, error} ->
        raise error
    end
  end

  @doc false
  def decrypt(config, ciphertext) do
    case find_module_to_decrypt(config, ciphertext) do
      nil ->
        {:error, Cloak.MissingCipher.exception(vault: config[:vault], ciphertext: ciphertext)}

      {_label, {module, opts}} ->
        module.decrypt(ciphertext, opts)
    end
  end

  @doc false
  def decrypt!(config, ciphertext) do
    case decrypt(config, ciphertext) do
      {:ok, plaintext} ->
        plaintext

      {:error, error} ->
        raise error
    end
  end

  defp find_module_to_decrypt(config, ciphertext) do
    Enum.find(config[:ciphers], fn {_label, {module, opts}} ->
      module.can_decrypt?(ciphertext, opts)
    end)
  end
end
