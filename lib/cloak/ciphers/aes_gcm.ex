defmodule Cloak.Ciphers.AES.GCM do
  @moduledoc """
  A `Cloak.Cipher` which encrypts values with the AES cipher in GCM (block) mode.
  Internally relies on Erlang's `:crypto.block_encrypt/4`.
  """

  @behaviour Cloak.Cipher

  alias Cloak.Tags.{Encoder, Decoder}
  alias Cloak.Crypto

  @aad "AES256GCM"
  @default_iv_length 16
  @cipher Crypto.map_cipher(:aes_256_gcm)

  @doc """
  Callback implementation for `Cloak.Cipher`. Encrypts a value using
  AES in GCM mode.

  Generates a random IV for every encryption, and prepends the key tag, IV,
  and ciphertag to the beginning of the ciphertext. The format can be
  diagrammed like this:

      +----------------------------------------------------------+----------------------+
      |                          HEADER                          |         BODY         |
      +-------------------+---------------+----------------------+----------------------+
      | Key Tag (n bytes) | IV (n bytes)  | Ciphertag (16 bytes) | Ciphertext (n bytes) |
      +-------------------+---------------+----------------------+----------------------+
      |                   |_________________________________
      |                                                     |
      +---------------+-----------------+-------------------+
      | Type (1 byte) | Length (1 byte) | Key Tag (n bytes) |
      +---------------+-----------------+-------------------+

  The `Key Tag` component of the header breaks down into a `Type`, `Length`,
  and `Value` triplet for easy decoding.

  **Important**: Because a random IV is used for every encryption, `encrypt/2`
  will not produce the same ciphertext twice for the same value.
  """
  @impl true
  def encrypt(plaintext, opts) do
    key = Keyword.fetch!(opts, :key)
    tag = Keyword.fetch!(opts, :tag)
    iv_length = Keyword.get(opts, :iv_length, @default_iv_length)
    iv = Crypto.strong_rand_bytes(iv_length)
    {ciphertext, ciphertag} = Crypto.encrypt_one_time_aead(@cipher, key, iv, @aad, plaintext)

    {:ok, Encoder.encode(tag) <> iv <> ciphertag <> ciphertext}
  end

  @doc """
  Callback implementation for `Cloak.Cipher`. Decrypts a value
  encrypted with AES in GCM mode.
  """
  @impl true
  def decrypt(ciphertext, opts) do
    if can_decrypt?(ciphertext, opts) do
      key = Keyword.fetch!(opts, :key)
      iv_length = Keyword.get(opts, :iv_length, @default_iv_length)

      %{remainder: <<iv::binary-size(iv_length), ciphertag::binary-16, ciphertext::binary>>} =
        Decoder.decode(ciphertext)

      plaintext = Crypto.decrypt_one_time_aead(@cipher, key, iv, @aad, ciphertext, ciphertag)
      {:ok, plaintext}
    else
      :error
    end
  end

  @doc """
  Callback implementation for `Cloak.Cipher`. Determines whether this module
  can decrypt the given ciphertext.
  """
  @impl true
  def can_decrypt?(ciphertext, opts) do
    tag = Keyword.fetch!(opts, :tag)
    iv_length = Keyword.get(opts, :iv_length, @default_iv_length)

    case Decoder.decode(ciphertext) do
      %{
        tag: ^tag,
        remainder: <<_iv::binary-size(iv_length), _ciphertag::binary-16, _ciphertext::binary>>
      } ->
        true

      _other ->
        false
    end
  end
end
