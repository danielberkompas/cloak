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

  ### Padding

  The length of a ciphertext reveals the length of its plaintext. For fields
  with only a few possible values, that can be enough to tell which value is
  stored. To prevent this, pass the `:padding` option when encrypting, and
  again when decrypting:

      {:ok, ciphertext} = MyApp.Vault.encrypt("yes", padding: true)

      MyApp.Vault.decrypt(ciphertext, padding: true)
      # => {:ok, "yes"}

  `padding: true` pads the plaintext to a multiple of 16 bytes. Pass an integer
  to pad to a multiple of that many bytes instead, e.g. `padding: 32`. Choose
  a size at least as large as the longest value you expect. See
  `Cloak.Padding` for details.

  A value that was encrypted with padding must be decrypted with padding, and
  vice versa.

  ### Performance Notes

  Vaults are not bottlenecks. They simply store configuration in an ETS table
  named after the Vault, e.g. `MyApp.Vault.Config`. All encryption and
  decryption is performed in your local process, reading configuration from
  the vault's ETS table.
  """

  @type plaintext :: binary
  @type ciphertext :: binary
  @type label :: atom
  @type opts :: [padding: boolean | pos_integer]

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

  If given a keyword list instead of a label, encrypts using the first
  configured cipher, with the given options.

  ## Options

  - `:padding` - Pads the plaintext before encryption, to hide its length.
    `true` pads to a multiple of 16 bytes, an integer pads to a multiple of
    that many bytes. Pass the same option to `decrypt/2`. (Default: `false`)
  """
  @callback encrypt(plaintext, label | opts) :: {:ok, ciphertext} | {:error, Exception.t()}

  @doc """
  Like `encrypt/2`, but raises any errors.
  """
  @callback encrypt!(plaintext, label | opts) :: ciphertext | no_return

  @doc """
  Encrypts a binary using the vault's configured cipher with the
  corresponding label. See `encrypt/2` for the available options.
  """
  @callback encrypt(plaintext, label, opts) :: {:ok, ciphertext} | {:error, Exception.t()}

  @doc """
  Like `encrypt/3`, but raises any errors.
  """
  @callback encrypt!(plaintext, label, opts) :: ciphertext | no_return

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
  Decrypts a binary like `decrypt/1`, with the given options.

  ## Options

  - `:padding` - Removes the padding from the decrypted plaintext. Must be
    set if the binary was encrypted with the `:padding` option. Returns a
    `Cloak.InvalidPadding` error if the plaintext is not padded.
    (Default: `false`)
  """
  @callback decrypt(ciphertext, opts) :: {:ok, plaintext} | {:error, Exception.t()}

  @doc """
  Like `decrypt/2`, but raises any errors.
  """
  @callback decrypt!(ciphertext, opts) :: plaintext | no_return

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

        case GenServer.start_link(__MODULE__, config, name: __MODULE__) do
          {:ok, pid} ->
            # Ensure that the configuration is saved
            GenServer.call(pid, :save_config, 10_000)
            # Return the pid
            {:ok, pid}

          other ->
            other
        end
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
        encrypt(plaintext, [])
      end

      @impl Cloak.Vault
      def encrypt!(plaintext) do
        encrypt!(plaintext, [])
      end

      @impl Cloak.Vault
      def encrypt(plaintext, label_or_opts) do
        with {:ok, config} <- Cloak.Vault.read_config(@table_name) do
          Cloak.Vault.encrypt(config, plaintext, label_or_opts)
        end
      end

      @impl Cloak.Vault
      def encrypt!(plaintext, label_or_opts) do
        case Cloak.Vault.read_config(@table_name) do
          {:ok, config} ->
            Cloak.Vault.encrypt!(config, plaintext, label_or_opts)

          {:error, error} ->
            raise error
        end
      end

      @impl Cloak.Vault
      def encrypt(plaintext, label, opts) do
        with {:ok, config} <- Cloak.Vault.read_config(@table_name) do
          Cloak.Vault.encrypt(config, plaintext, label, opts)
        end
      end

      @impl Cloak.Vault
      def encrypt!(plaintext, label, opts) do
        case Cloak.Vault.read_config(@table_name) do
          {:ok, config} ->
            Cloak.Vault.encrypt!(config, plaintext, label, opts)

          {:error, error} ->
            raise error
        end
      end

      @impl Cloak.Vault
      def decrypt(ciphertext) do
        decrypt(ciphertext, [])
      end

      @impl Cloak.Vault
      def decrypt!(ciphertext) do
        decrypt!(ciphertext, [])
      end

      @impl Cloak.Vault
      def decrypt(ciphertext, opts) do
        with {:ok, config} <- Cloak.Vault.read_config(@table_name) do
          Cloak.Vault.decrypt(config, ciphertext, opts)
        end
      end

      @impl Cloak.Vault
      def decrypt!(ciphertext, opts) do
        case Cloak.Vault.read_config(@table_name) do
          {:ok, config} ->
            Cloak.Vault.decrypt!(config, ciphertext, opts)

          {:error, error} ->
            raise error
        end
      end

      @impl Cloak.Vault
      def json_library do
        with {:ok, config} <- Cloak.Vault.read_config(@table_name) do
          Keyword.get(config, :json_library, Jason)
        end
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
    [{:config, config} | _] = :ets.lookup(table_name, :config)
    {:ok, config}
  rescue
    ArgumentError ->
      {:error, Cloak.VaultNotStarted.exception(table_name)}
  end

  @doc false
  def encrypt(config, plaintext, label_or_opts \\ [])

  def encrypt(config, plaintext, opts) when is_list(opts) do
    with [{_label, {module, cipher_opts}} | _ciphers] <- config[:ciphers] do
      plaintext
      |> pad(opts[:padding])
      |> module.encrypt(cipher_opts)
    else
      _ ->
        {:error, Cloak.InvalidConfig.exception("could not encrypt due to missing configuration")}
    end
  end

  def encrypt(config, plaintext, label) do
    encrypt(config, plaintext, label, [])
  end

  @doc false
  def encrypt(config, plaintext, label, opts) do
    case config[:ciphers][label] do
      nil ->
        {:error, Cloak.MissingCipher.exception(vault: config[:vault], label: label)}

      {module, cipher_opts} ->
        plaintext
        |> pad(opts[:padding])
        |> module.encrypt(cipher_opts)
    end
  end

  @doc false
  def encrypt!(config, plaintext, label_or_opts \\ []) do
    config
    |> encrypt(plaintext, label_or_opts)
    |> unwrap!()
  end

  @doc false
  def encrypt!(config, plaintext, label, opts) do
    config
    |> encrypt(plaintext, label, opts)
    |> unwrap!()
  end

  @doc false
  def decrypt(config, ciphertext, opts \\ []) do
    case find_module_to_decrypt(config, ciphertext) do
      nil ->
        {:error, Cloak.MissingCipher.exception(vault: config[:vault], ciphertext: ciphertext)}

      {_label, {module, cipher_opts}} ->
        with {:ok, plaintext} <- module.decrypt(ciphertext, cipher_opts) do
          unpad(plaintext, opts[:padding])
        end
    end
  end

  @doc false
  def decrypt!(config, ciphertext, opts \\ []) do
    config
    |> decrypt(ciphertext, opts)
    |> unwrap!()
  end

  defp unwrap!({:ok, result}), do: result
  defp unwrap!({:error, error}), do: raise(error)

  defp pad(plaintext, padding) when padding in [nil, false], do: plaintext
  defp pad(plaintext, true), do: Cloak.Padding.pad(plaintext)

  defp pad(plaintext, size) when is_integer(size) and size > 0,
    do: Cloak.Padding.pad(plaintext, size)

  defp pad(_plaintext, padding) do
    raise ArgumentError,
          "expected :padding to be a boolean or a positive integer, got: #{inspect(padding)}"
  end

  defp unpad(plaintext, padding) when padding in [nil, false], do: {:ok, plaintext}

  defp unpad(plaintext, _padding) do
    with :error <- Cloak.Padding.unpad(plaintext) do
      {:error, Cloak.InvalidPadding.exception([])}
    end
  end

  defp find_module_to_decrypt(config, ciphertext) do
    Enum.find(config[:ciphers], fn {_label, {module, opts}} ->
      module.can_decrypt?(ciphertext, opts)
    end)
  end
end
