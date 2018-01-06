defmodule Cloak.AES.GCM do
  @moduledoc """
  A `Cloak.Cipher` which encrypts values with the AES cipher in GCM (block) mode.
  Internally relies on Erlang's `:crypto.block_encrypt/4`.

  ## Configuration

  In addition to the normal `:default` and `tag` configuration options, this
  cipher take a `:keys` option to support using multiple AES keys at the same time.

      config :cloak, Cloak.AES.GCM,
        default: true,
        tag: "GCM",
        keys: [
          %{tag: <<1>>, key: Base.decode64!("..."), default: false},
          %{tag: <<2>>, key: Base.decode64!("..."), default: true}
        ]

  If you want to store your key in the environment variable, you can use
  `{:system, "VAR"}` syntax:

      config :cloak, Cloak.AES.GCM,
        default: true,
        tag: "GCM",
        keys: [
          %{tag: <<1>>, key: {:system, "CLOAK_KEY_PRIMARY"}, default: true},
          %{tag: <<2>>, key: {:system, "CLOAK_KEY_SECONDARY"}, default: false}
        ]

  If you want to store your key in the OTP app environment, you can use
  `{:app_env, :otp_app, :env_key}` syntax:

      config :cloak, Cloak.AES.GCM,
        default: true,
        tag: "GCM",
        keys: [
          %{tag: <<1>>, key: {:app_env, :my_app, :env_primary_key}, default: true},
          %{tag: <<2>>, key: {:app_env, :my_app, :env_secondary_key}, default: false}
        ]

  ### Key Configuration Options

  A key may have the following attributes:

  - `:tag` - The ID of the key. This is included in the ciphertext, and should be
    only a single byte. See `encrypt/2` for more details.

  - `:key` - The AES key to use, in binary. If you store your keys in Base64
    format you will need to decode them first. The key must be 128, 192, or 256 bits
    long (16, 24 or 32 bytes, respectively).

  - `:default` - Boolean. Whether to use this key by default or not.

  ## Upgrading to a New Key

  To upgrade to a new key, simply add the key to the `:keys` array, and set it
  as `default: true`.

      keys: [
        %{tag: <<1>>, key: "old key", default: false},
        %{tag: <<2>>, key: "new key", default: true}
      ]

  After this, your new key will automatically be used for all new encyption,
  while the old key will be used to decrypt legacy values.

  To migrate everything proactively to the new key, see the `mix cloak.migrate`
  mix task defined in `Mix.Tasks.Cloak.Migrate`.
  """

  import Cloak.Tags.Encoder
  import Cloak.Tags.Decoder

  @behaviour Cloak.Cipher
  @aad "AES256GCM"

  @doc """

  Callback implementation for `Cloak.Cipher.encrypt`. Encrypts a value using
  AES in CTR mode.

  Generates a random IV for every encryption, and prepends the key tag, IV, and Ciphertag to
  the beginning of the ciphertext. The format can be diagrammed like this:

      +----------------------------------------------------------+----------------------+
      |                          HEADER                          |         BODY         |
      +-------------------+---------------+----------------------+----------------------+
      | Key Tag (n bytes) | IV (16 bytes) | Ciphertag (16 bytes) | Ciphertext (n bytes) |
      +-------------------+---------------+----------------------+----------------------+

  When this function is called through `Cloak.encrypt/1`, the module's `:tag`
  will be added, and the resulting binary will be in this format:

      +---------------------------------------------------------------------------------+----------------------+
      |                                       HEADER                                    |         BODY         |
      +----------------------+-------------------+---------------+----------------------+----------------------+
      | Module Tag (n bytes) | Key Tag (n bytes) | IV (16 bytes) | Ciphertag (16 bytes) | Ciphertext (n bytes) |
      +----------------------+-------------------+---------------+----------------------+----------------------+

  The header information allows Cloak to know enough about each ciphertext to
  ensure a successful decryption. See `decrypt/1` for more details.

  **Important**: Because a random IV is used for every encryption, `encrypt/2`
  will not produce the same ciphertext twice for the same value.

  ### Parameters

  - `plaintext` - Any type of value to encrypt.
  - `key_tag` - Optional. The tag of the key to use for encryption.

  ### Examples

      iex> encrypt("The charge against me is a...") != "The charge against me is a..."
      true

      iex> encrypt("The charge against me is a...") != encrypt("The charge against me is a...")
      true

  """

  def encrypt(plain_text, key_tag \\ nil) do
    perform_encryption(plain_text, iv(), find_key(key_tag))
  end

  defp perform_encryption(plaintext, iv, key) do
    {ciphertext, ciphertag} =
      :crypto.block_encrypt(
        :aes_gcm,
        Cloak.Ciphers.Util.key_value(key),
        iv,
        {@aad, plaintext}
      )

    encode(key.tag) <> iv <> ciphertag <> ciphertext
  end

  @doc """
  Callback implementation for `Cloak.Cipher.decrypt/2`. Decrypts a value
  encrypted with AES in GCM mode.

  Uses the key tag to find the correct key for decryption, and the IV and Ciphertag included
  in the header to decrypt the body of the ciphertext.

  ### Parameters

  - `ciphertext` - Binary ciphertext generated by `encrypt/2`.

  ### Examples

      iex> encrypt("Hello") |> decrypt
      "Hello"
  """

  def decrypt(message) do
    %{key_tag: key_tag, remainder: remainder} = decode(message)

    perform_decryption(
      Cloak.Ciphers.Util.key_value(find_key(key_tag)),
      remainder
    )
  end

  defp perform_decryption(key, <<iv::binary-16, ciphertag::binary-16, ciphertext::binary>>) do
    :crypto.block_decrypt(:aes_gcm, key, iv, {@aad, ciphertext, ciphertag})
  end

  defp iv, do: :crypto.strong_rand_bytes(16)

  defp find_key(key_tag) do
    Cloak.Ciphers.Util.config(__MODULE__, key_tag) || default_key()
  end

  defp default_key, do: Cloak.Ciphers.Util.default_key(__MODULE__)

  @doc """
    Callback implementation for `Cloak.Cipher.version/0`. Returns the tag of the
    current default key.
  """
  def version, do: default_key().tag
end
