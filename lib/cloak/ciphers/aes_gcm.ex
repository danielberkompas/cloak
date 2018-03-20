defmodule Cloak.Cipher.AES.GCM do
  @moduledoc """
  A `Cloak.Cipher` which encrypts values with the AES cipher in GCM (block) mode.
  Internally relies on Erlang's `:crypto.block_encrypt/4`.
  """

  @behaviour Cloak.Cipher
  @aad "AES256GCM"

  alias Cloak.Tags.Encoder
  alias Cloak.Tags.Decoder

  @doc """
  Callback implementation for `Cloak.Cipher.encrypt/2`. Encrypts a value using
  AES in GCM mode.

  Generates a random IV for every encryption, and prepends the key tag, IV,
  and ciphertag to the beginning of the ciphertext. The format can be
  diagrammed like this:

      +----------------------------------------------------------+----------------------+
      |                          HEADER                          |         BODY         |
      +-------------------+---------------+----------------------+----------------------+
      | Key Tag (n bytes) | IV (16 bytes) | Ciphertag (16 bytes) | Ciphertext (n bytes) |
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
  def encrypt(plaintext, opts) do
    key = Keyword.fetch!(opts, :key)
    tag = Keyword.fetch!(opts, :tag)
    iv = generate_iv()

    {ciphertext, ciphertag} =
      :crypto.block_encrypt(
        :aes_gcm,
        key,
        iv,
        {@aad, plaintext}
      )

    {:ok, Encoder.encode(tag) <> iv <> ciphertag <> ciphertext}
  end

  @doc """
  Callback implementation for `Cloak.Cipher.decrypt/2`. Decrypts a value
  encrypted with AES in GCM mode.
  """
  def decrypt(ciphertext, opts) do
    if can_decrypt?(ciphertext, opts) do
      key = Keyword.fetch!(opts, :key)

      %{remainder: <<iv::binary-16, ciphertag::binary-16, ciphertext::binary>>} =
        Decoder.decode(ciphertext)

      {:ok, :crypto.block_decrypt(:aes_gcm, key, iv, {@aad, ciphertext, ciphertag})}
    else
      :error
    end
  end

  @doc """
  Callback implementation for `Cloak.Cipher.can_decrypt?/2`. Determines whether
  this module can decrypt the given ciphertext.
  """
  def can_decrypt?(ciphertext, opts) do
    tag = Keyword.fetch!(opts, :tag)

    case Decoder.decode(ciphertext) do
      %{tag: ^tag, remainder: <<_iv::binary-16, _ciphertag::binary-16, _ciphertext::binary>>} ->
        true

      _other ->
        false
    end
  end

  defp generate_iv, do: :crypto.strong_rand_bytes(16)

  @doc """
  Callback implementation for `Cloak.Cipher.version/0`. Returns the tag of the
  current default key.
  """
  def version(opts), do: Keyword.fetch!(opts, :tag)
end
