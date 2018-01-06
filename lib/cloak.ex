defmodule Cloak do
  @moduledoc """
  Cloak makes it easy to encrypt and decrypt database fields using
  [Ecto](http://hexdocs.pm/ecto).

  This `Cloak` module is Cloak's main entry point. It wraps the encryption
  and decryption process, ensuring that everything works smoothly without
  downtime, even when there are multiple encryption ciphers and keys in play
  at the same time.

  ## Configuration

  The actual encryption work is delegated to the cipher module that you specify
  in Cloak's configuration. Cipher modules must adhere to the `Cloak.Cipher`
  behaviour. You can configure a cipher module like so:

      config :cloak, ModuleName,
        default: true,
        tag: "TAG",
        # any other attributes required by the cipher

  You can also have multiple ciphers configured at the same time, provided that
  they are not both set to `default: true`.

      config :cloak, CipherOne,
        default: true,
        tag: "one",
        # ...

      config :cloak, CipherTwo,
        default: true,
        tag: "two",
        # ...

  ### Options

  Both of these options are required for every cipher:

  - `:default` - Boolean. Determines whether this module will be the default
    module for encryption or decryption. The default module will be used to
    generate all new encrypted values.

  - `:tag` - Binary. Used to tag any ciphertext that the cipher module
    generates. This allows Cloak to decrypt a ciphertext with the correct module
    when you have multiple ciphers in use at the same time.

  If your cipher module requires additional configuration options, you can also
  add those keys and values to this configuration.

      # Example of custom settings for a cipher module
      config :cloak, MyCustomCipher,
        default: true,
        tag: "tag",
        custom_setting1: "...",
        custom_setting2: "..."

  It will be the responsibility of the cipher module to read these values from
  the `:cloak` application configuration and use them.

  ## Provided Ciphers

  - `Cloak.AES.GCM` (recommended) - AES encryption in Galois Counter Mode (GCM).
  - `Cloak.AES.CTR` - AES encryption in CTR stream mode.

  If you don't see what you need here, you can use your own cipher module,
  provided it adheres to the `Cloak.Cipher` behaviour.

  (And [open a PR](https://github.com/danielberkompas/cloak), please!)

  ## Ecto Integration

  Once Cloak is configured with a Cipher module, you can use it seamlessly with
  [Ecto](http://hex.pm/ecto) with these `Ecto.Type` modules:

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

  You can also use the following `Ecto.Type` modules in order to hash fields:

  | Type      | Ecto Type              | Field               | 
  | --------- | ---------------------- | ------------------- |
  | `String`  | `:string` / `:binary`  | `Cloak.SHA265Field` |

  For example, to encrypt a binary field, change your schema from this:

      schema "users" do
        field :name, :binary
      end

  To this:

      schema "users" do
        field :name, Cloak.EncryptedBinaryField
      end

  The `name` field will then be encrypted whenever it is saved to the database,
  using your configured cipher module. It will also be transparently decrypted
  whenever the user is loaded from the database.

  ## Examples

  The `Cloak` module can be called directly to generate ciphertext using the
  current default cipher module.

      iex> Cloak.encrypt("Hello") != "Hello"
      true

      iex> Cloak.encrypt("Hello") |> Cloak.decrypt
      "Hello"

      iex> Cloak.version
      <<"AES", 1>>
  """

  @doc """
  Encrypt a value using the cipher module associated with the tag.

  The `:tag` of the cipher will be prepended to the output. So, if the cipher
  was `Cloak.AES.CTR`, and the tag was "AES", the output would be in this
  format:

      +-------+---------------+
      | "AES" | Cipher output |
      +-------+---------------+

  This tagging allows Cloak to delegate decryption of a ciphertext to the
  correct module when you have multiple ciphers in use at the same time. (For
  example, this can occur while you migrate your encrypted data to a new
  cipher.)

  ### Parameters

  - `plaintext` - The value to be encrypted.

  ### Optional Parameters

  - `tag` - The tag of the cipher to use for encryption. If omitted,
    will default to the default cipher.

  ### Example
      Cloak.encrypt("Hello, World!")
      <<"AES", ...>>

      Cloak.encrypt("Hello, World!", "AES")
      <<"AES", ...>>
  """
  @spec encrypt(term, String.t() | nil) :: String.t()
  def encrypt(plaintext, tag \\ nil)

  def encrypt(plaintext, nil) do
    default_tag() <> default_cipher().encrypt(plaintext)
  end

  def encrypt(plaintext, tag) do
    tag <> cipher(tag).encrypt(plaintext)
  end

  @doc """
  Decrypt a ciphertext with the cipher module it was encrypted with.

  `encrypt/1` includes the `:tag` of the cipher module that generated the
  encryption in the ciphertext it outputs. `decrypt/1` can then use this tag to
  find the right module on decryption.

  ### Parameters

  - `ciphertext` - A binary of ciphertext generated by `encrypt/1`.

  ### Example

  If the cipher module responsible had the tag "AES", Cloak will find the module
  using that tag, strip it off, and hand the remaining ciphertext to the module
  for decryption.

      iex> ciphertext = Cloak.encrypt("Hello world!")
      ...> <<"AES", _ :: bitstring>> = ciphertext
      ...> Cloak.decrypt(ciphertext)
      "Hello world!"
  """
  def decrypt(ciphertext) do
    plaintexts =
      Cloak.Config.all()
      |> Enum.filter(fn {_cipher, config} ->
        tag = config[:tag]
        String.starts_with?(ciphertext, tag)
      end)
      |> Enum.map(fn {cipher, config} ->
        tag = config[:tag]
        tag_size = byte_size(tag)
        ciphertext = binary_part(ciphertext, tag_size, byte_size(ciphertext) - tag_size)
        cipher.decrypt(ciphertext)
      end)

    case plaintexts do
      [plaintext | _] ->
        plaintext

      _ ->
        raise ArgumentError, "No cipher found to decrypt #{inspect(ciphertext)}."
    end
  end

  @doc """
  Returns the default cipher module's tag combined with the result of that
  cipher's `version/0` function.

  It is used in changesets to record which cipher was used to encrypt a row
  in a database table. This is very useful when migrating to a new cipher or new
  encryption key, because you'd be able to query your database to find records
  that need to be migrated.
  """
  @spec version() :: String.t()
  def version() do
    default_tag() <> default_cipher().version()
  end

  @spec default_cipher() :: module
  defp default_cipher do
    {cipher, _config} = Cloak.Config.default_cipher()
    cipher
  end

  @spec default_tag() :: String.t()
  defp default_tag do
    {_cipher, config} = Cloak.Config.default_cipher()
    config[:tag]
  end

  @spec version(String.t()) :: String.t()
  def version(tag) do
    tag <> cipher(tag).version()
  end

  @spec cipher(String.t()) :: module
  defp cipher(tag) do
    {cipher, _config} = Cloak.Config.cipher(tag)
    cipher
  end
end
