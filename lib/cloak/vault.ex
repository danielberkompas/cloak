defmodule Cloak.Vault do
  @moduledoc """
  Encrypts and decrypts data, using a configured cipher.

  ## Create Your Vault

  Define a module in your application that uses `Cloak.Vault`.

      defmodule MyApp.Vault do
        use Cloak.Vault, otp_app: :my_app
      end

  ## Configuration

  The `:otp_app` option should point to an OTP application that has the vault
  configuration.

  For example, the vault:

      defmodule MyApp.Vault do
        use Cloak.Vault, otp_app: :my_app
      end

  Could be configured with Mix configuration like so:

      config :my_app, MyApp.Vault,
        json_library: Jason,
        ciphers: [
          default: {Cloak.Ciphers.AES.GCM, tag: "AES.GCM.V1", key: <<...>>}
        ]

  The configuration options are:

  - `:json_library`: Used to convert data types like lists and maps into
    binary so that they can be encrypted. (Default: `Jason`)

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

  You can use the vault directly by calling its functions.

      MyApp.Vault.encrypt("plaintext")
      # => {:ok, <<...>>}

      MyApp.Vault.decrypt(ciphertext)
      # => {:ok, "plaintext"}

  See the documented callbacks below for the functions you can call.

  ### Performance Notes

  Vaults are not bottlenecks. They simply store configuration in a
  `:persistent_term` named after the Vault, e.g. `MyApp.Vault.Config`.
  All encryption and decryption is performed in your local process,
  reading configuration from the vault's `:persistent_term`.
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
      @config_key :"#{__MODULE__}.Config"

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
        Cloak.Vault.save_config(@config_key, config)
        {:reply, :ok, config}
      end

      # If a hot upgrade occurs, rerun the `init` callback to
      # refresh the configuration in case it changed
      @impl GenServer
      def code_change(_vsn, config, _extra) do
        config = init(config)
        Cloak.Vault.save_config(@config_key, config)
        {:ok, config}
      end

      ###
      # Encrypt/Decrypt functions
      ###

      @impl Cloak.Vault
      def encrypt(plaintext) do
        @config_key
        |> Cloak.Vault.read_config()
        |> Cloak.Vault.encrypt(plaintext)
      end

      @impl Cloak.Vault
      def encrypt!(plaintext) do
        @config_key
        |> Cloak.Vault.read_config()
        |> Cloak.Vault.encrypt!(plaintext)
      end

      @impl Cloak.Vault
      def encrypt(plaintext, label) do
        @config_key
        |> Cloak.Vault.read_config()
        |> Cloak.Vault.encrypt(plaintext, label)
      end

      @impl Cloak.Vault
      def encrypt!(plaintext, label) do
        @config_key
        |> Cloak.Vault.read_config()
        |> Cloak.Vault.encrypt!(plaintext, label)
      end

      @impl Cloak.Vault
      def decrypt(ciphertext) do
        @config_key
        |> Cloak.Vault.read_config()
        |> Cloak.Vault.decrypt(ciphertext)
      end

      @impl Cloak.Vault
      def decrypt!(ciphertext) do
        @config_key
        |> Cloak.Vault.read_config()
        |> Cloak.Vault.decrypt!(ciphertext)
      end

      @impl Cloak.Vault
      def json_library do
        @config_key
        |> Cloak.Vault.read_config()
        |> Keyword.get(:json_library, Jason)
      end

      defoverridable(Module.definitions_in(__MODULE__))
    end
  end

  defmacrop unsafe(input) do
    quote do
      case unquote(input) do
        {:ok, some_result} -> some_result
        {:error, error} -> raise error
      end
    end
  end

  @doc false
  def save_config(key, config) do
    :persistent_term.put(key, config)
  end

  @doc false
  def read_config(key) do
    :persistent_term.get(key)
  rescue
    _ in ArgumentError -> :error
  end

  @doc false
  def encrypt(config, plaintext) do
    case config[:ciphers] do
      [{_label, {module, opts}} | _ciphers] ->
        module.encrypt(plaintext, opts)

      _ ->
        {:error, Cloak.InvalidConfig.exception("could not encrypt due to missing configuration")}
    end
  end

  @doc false
  def encrypt!(config, plaintext) do
    unsafe encrypt(config, plaintext)
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
    unsafe encrypt(config, plaintext, label)
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
    unsafe decrypt(config, ciphertext)
  end

  defp find_module_to_decrypt(config, ciphertext) do
    Enum.find(config[:ciphers], fn {_label, {module, opts}} ->
      module.can_decrypt?(ciphertext, opts)
    end)
  end
end
