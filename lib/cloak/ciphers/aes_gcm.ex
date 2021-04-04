defmodule Cloak.Ciphers.AES.GCM do
  @moduledoc """
  A `Cloak.Cipher` which encrypts values with the AES cipher in GCM (block) mode.
  Internally relies on Erlang's `:crypto.block_encrypt/4`.
  """

  @behaviour Cloak.Cipher
  @aad "AES256GCM"
  @default_iv_length 16

  alias Cloak.Tags.Encoder
  alias Cloak.Tags.Decoder

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
    iv = :crypto.strong_rand_bytes(iv_length)

    {ciphertext, ciphertag} = do_encrypt(key, iv, plaintext)
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

      {:ok, do_decrypt(key, iv, ciphertext, ciphertag)}
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

  # TODO: remove this once support for Erlang/OTP 21 is dropped
  if System.otp_release() >= "22" do
    defp do_decrypt(key, iv, ciphertext, ciphertag) do
      :crypto.crypto_one_time_aead(:aes_256_gcm, key, iv, ciphertext, @aad, ciphertag, false)
    end

    defp do_encrypt(key, iv, plaintext) do
      :crypto.crypto_one_time_aead(:aes_256_gcm, key, iv, plaintext, @aad, true)
    end
  else
    defp do_decrypt(key, iv, ciphertext, ciphertag) do
      :crypto.block_decrypt(:aes_gcm, key, iv, {@aad, ciphertext, ciphertag})
    end

    defp do_encrypt(key, iv, plaintext) do
      :crypto.block_encrypt(:aes_gcm, key, iv, {@aad, plaintext})
    end
  end
end
