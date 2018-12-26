if Code.ensure_loaded?(:pbkdf2) do
  defmodule Cloak.Fields.PBKDF2 do
    @moduledoc """
    A custom `Ecto.Type` for deriving a key for fields using
    [PBKDF2](https://en.wikipedia.org/wiki/PBKDF2).

    PBKDF2 is **more secure** than `Cloak.Fields.HMAC` and
    `Cloak.Fields.SHA256` because it uses [key
    stretching](https://en.wikipedia.org/wiki/Key_stretching) to increase the
    amount of time to compute hashes. This slows down brute-force attacks.

    ## Why

    If you store a hash of a field's value, you can then query on it as a
    proxy for an encrypted field. This works because PBKDF2 is deterministic
    and always results in the same value, while secure encryption does not.
    Be warned, however, that hashing will expose which fields have the same
    value, because they will contain the same hash.

    ## Dependency

    To use this field type, you must install the `:pbkdf2` library in your
    `mix.exs` file.

        {:pbkdf2, "~> 2.0"}

    ## Configuration

    Create a `PBKDF2` field in your project:

        defmodule MyApp.Hashed.PBKDF2 do
          use Cloak.Fields.PBKDF2, otp_app: :my_app
        end

    Then, configure it with a `:secret`, an `:algorithm`, the maximum `:size`
    of the stored key (in bytes), and a number of `:iterations`, either using
    mix configuration:

        config :my_app, MyApp.Hashed.PBKDF2,
          algorithm: :sha256,
          iterations: 10_000,
          secret: "secret",
          size: 64

    Or using the `init/1` callback to fetch configuration at runtime:

        defmodule MyApp.Hashed.PBKDF2 do
          use Cloak.Fields.PBKDF2, otp_app: :my_app

          @impl Cloak.Fields.PBKDF2
          def init(config) do
            config = Keyword.merge(config, [
              algorithm: :sha256,
              iterations: 10_000,
              secret: System.get_env("PBKDF2_SECRET")
            ])

            {:ok, config}
          end
        end

    ## Usage

    Create the hash field with the type `:binary`. Add it to your schema
    definition like this:

        schema "table" do
          field :field_name, MyApp.Encrypted.Binary
          field :field_name_hash, MyApp.Hashed.PBKDF2
        end

    Ensure that the hash is updated whenever the target field changes with the
    `put_change/3` function:

        def changeset(struct, attrs \\\\ %{}) do
          struct
          |> cast(attrs, [:field_name, :field_name_hash])
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

    @typedoc "Digest algorithms supported by Cloak.Field.PBKDF2"
    @type algorithms :: :md4 | :md5 | :ripemd160 | :sha | :sha224 | :sha256 | :sha384 | :sha512

    @doc """
    Configures the `PBKDF2` field using runtime information.

    ## Example

        @impl Cloak.Fields.PBKDF2
        def init(config) do
          config = Keyword.merge(config, [
            algorithm: :sha256,
            secret: System.get_env("PBKDF2_SECRET")
          ])

          {:ok, config}
        end
    """
    @callback init(config :: Keyword.t()) :: {:ok, Keyword.t()} | {:error, any}

    @doc false
    defmacro __using__(opts) do
      otp_app = Keyword.fetch!(opts, :otp_app)

      quote do
        @behaviour Cloak.Fields.PBKDF2
        @behaviour Ecto.Type
        @algorithms ~w[
          md4
          md5
          ripemd160
          sha
          sha224
          sha256
          sha384
          sha512
        ]a

        @impl Cloak.Fields.PBKDF2
        def init(config) do
          defaults = [algorithm: :sha256, iterations: 10_000, size: 32]

          {:ok, defaults |> Keyword.merge(config)}
        end

        @impl Ecto.Type
        def type, do: :binary

        @impl Ecto.Type
        def cast(nil), do: {:ok, nil}
        def cast(value) when is_binary(value), do: {:ok, value}
        def cast(_value), do: :error

        @impl Ecto.Type
        def dump(nil), do: {:ok, nil}

        def dump(value) when is_binary(value) do
          config = build_config()
          :pbkdf2.pbkdf2({:hmac, config[:algorithm]}, value, config[:secret], config[:size])
        end

        def dump(_value), do: :error

        @impl Ecto.Type
        def load(value), do: {:ok, value}

        defoverridable init: 1, type: 0, cast: 1, dump: 1, load: 1

        defp build_config do
          {:ok, config} =
            unquote(otp_app)
            |> Application.get_env(__MODULE__, [])
            |> init()

          validate_config(config)
        end

        defp validate_config(config) do
          m = inspect(__MODULE__)

          unless is_binary(config[:secret]) do
            secret = inspect(config[:secret])

            raise Cloak.InvalidConfig, "#{secret} is an invalid secret for #{m}"
          end

          unless config[:algorithm] in @algorithms do
            algo = inspect(config[:algorithm])

            raise Cloak.InvalidConfig,
                  "#{algo} is an invalid hash algorithm for #{m}"
          end

          unless is_integer(config[:iterations]) && config[:iterations] > 0 do
            iterations = inspect(config[:iterations])

            raise Cloak.InvalidConfig,
                  "Iterations must be a positive integer for #{m}, got: #{iterations}"
          end

          unless is_integer(config[:size]) && config[:size] > 0 do
            size = inspect(config[:size])

            raise Cloak.InvalidConfig,
                  "Size should be a positive integer for #{m}, got: #{size}"
          end

          config
        end
      end
    end
  end
end
