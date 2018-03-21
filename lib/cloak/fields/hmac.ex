defmodule Cloak.Fields.HMAC do
  @moduledoc """
  A custom `Ecto.Type` for hashing fields using `:crypto.hmac/3`.

  HMAC is **more secure** than `Cloak.Fields.SHA256`, because it uses a secret
  to obfuscate the hash. This makes it harder to guess the value of the field.

  ## Why

  If you store a hash of a field's value, you can then query on it as a proxy
  for an encrypted field. This works because HMAC is deterministic and
  always results in the same value, while secure encryption does not. Be
  warned, however, that hashing will expose which fields have the same value,
  because they will contain the same hash.

  ## Configuration

  Create an `HMAC` field in your project:

      defmodule MyApp.Hashed.HMAC do
        use Cloak.Fields.HMAC, otp_app: :my_app
      end

  Then, configure it with a `:secret` and `:algorithm`, either using
  mix configuration:

      config :my_app, MyApp.Hashed.HMAC,
        algorithm: :sha512,
        secret: "secret"

  Or using the `init/1` callback to fetch configuration at runtime:

      defmodule MyApp.Hashed.HMAC do
        use Cloak.Fields.HMAC, otp_app: :my_app

        @impl Cloak.Fields.HMAC
        def init(config) do
          config = Keyword.merge(config, [
            algorithm: :sha512,
            secret: System.get_env("HMAC_SECRET")
          ])

          {:ok, config}
        end
      end

  ## Usage

  Create the hash field with the type `:binary`. Add it to your schema
  definition like this:

      schema "table" do
        field :field_name, MyApp.Encrypted.Binary
        field :field_name_hash, MyApp.Hashed.HMAC
      end

  Ensure that the hash is updated whenever the target field changes with the
  `put_change/3` function:

      def changeset(struct, params \\ %{}) do
        struct
        |> cast(params, [:field_name, :field_name_hash])
        |> put_hashed_fields()
      end

      defp put_hashed_fields(changeset) do
        changeset
        |> put_change(:field_name_hash, get_field(changeset, :field_name))
      end

  Query the Repo using the `:field_name_hash` in any place you would typically
  query by `:field_name`.

      user = Repo.get_by(User, email_hash: "user@email.com")
  """

  @typedoc "HMAC algorithms supported by Cloak.Field.HMAC"
  @type algorithms :: :md5 | :ripemd160 | :sha | :sha224 | :sha256 | :sha384 | :sha512

  @doc """
  Configures the `HMAC` field using runtime information.

  ## Example

      @impl Cloak.Fields.HMAC
      def init(config) do
        config = Keyword.merge(config, [
          algorithm: :sha512,
          secret: System.get_env("HMAC_SECRET")
        ])

        {:ok, config}
      end
  """
  @callback init(config :: Keyword.t()) :: {:ok, Keyword.t()} | {:error, any}

  @doc false
  defmacro __using__(opts) do
    otp_app = Keyword.fetch!(opts, :otp_app)

    quote do
      @behaviour Cloak.Fields.HMAC
      @behaviour Ecto.Type
      @algorithms ~w[
        md5
        ripemd160
        sha
        sha224
        sha256
        sha384
        sha512
      ]a

      @impl Cloak.Fields.HMAC
      def init(config) do
        {:ok, config}
      end

      @impl Ecto.Type
      def type, do: :binary

      @impl Ecto.Type
      def cast(nil) do
        {:ok, nil}
      end

      def cast(value) when is_binary(value) do
        {:ok, value}
      end

      def cast(_value) do
        :error
      end

      @impl Ecto.Type
      def dump(nil) do
        {:ok, nil}
      end

      def dump(value) when is_binary(value) do
        config = build_config()
        {:ok, :crypto.hmac(config[:algorithm], config[:secret], value)}
      end

      def dump(_value) do
        :error
      end

      @impl Ecto.Type
      def load(value) do
        {:ok, value}
      end

      defoverridable init: 1, type: 0, cast: 1, dump: 1, load: 1

      defp build_config do
        {:ok, config} =
          unquote(otp_app)
          |> Application.get_env(__MODULE__, [])
          |> init()

        validate_config(config)
      end

      defp validate_config(config) do
        unless is_binary(config[:secret]) do
          secret = inspect(config[:secret])

          raise Cloak.InvalidConfig, "#{secret} is an invalid secret for #{inspect(__MODULE__)}"
        end

        unless config[:algorithm] in @algorithms do
          algo = inspect(config[:algorithm])

          raise Cloak.InvalidConfig,
                "#{algo} is an invalid hash algorithm for #{inspect(__MODULE__)}"
        end

        config
      end
    end
  end
end
