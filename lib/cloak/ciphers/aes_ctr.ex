defmodule Cloak.Ciphers.AES.CTR do
  @moduledoc """
  A `Cloak.Cipher` which encrypts values with the AES cipher in CTR (stream) mode.
  Internally relies on Erlang's `:crypto.stream_encrypt/2`.
  """

  @behaviour Cloak.Cipher

  alias Cloak.Tags.{Encoder, Decoder}

  @doc """
  Callback implementation for `Cloak.Cipher`. Encrypts a value using
  AES in CTR mode.

  Generates a random IV for every encryption, and prepends the key tag and IV to
  the beginning of the ciphertext. The format can be diagrammed like this:

      +-----------------------------------+----------------------+
      |               HEADER              |         BODY         |
      +-------------------+---------------+----------------------+
      | Key Tag (n bytes) | IV (16 bytes) | Ciphertext (n bytes) |
      +-------------------+---------------+----------------------+
      |                   |__________________________________
      |                                                     |
      +---------------+-----------------+-------------------+
      | Type (1 byte) | Length (1 byte) | Key Tag (n bytes) |
      +---------------+-----------------+-------------------+

  The `Key Tag` component of the header breaks down into a `Type`, `Length`,
  and `Value` triplet for easy decoding.
  """
  @impl true
  def encrypt(plaintext, opts) when is_binary(plaintext) do
    key = Keyword.fetch!(opts, :key)
    tag = Keyword.fetch!(opts, :tag)

    iv = :crypto.strong_rand_bytes(16)
    state = do_init(key, iv, true)

    ciphertext = do_encrypt(state, to_string(plaintext))
    {:ok, Encoder.encode(tag) <> iv <> ciphertext}
  end

  @doc """
  Callback implementation for `Cloak.Cipher`. Decrypts a value
  encrypted with AES in CTR mode.

  Uses the key tag to find the correct key for decryption, and the IV included
  in the header to decrypt the body of the ciphertext.

  ### Parameters

  - `ciphertext` - Binary ciphertext generated by `encrypt/2`.

  ### Examples

      iex> encrypt("Hello") |> decrypt
      "Hello"
  """
  @impl true
  def decrypt(ciphertext, opts) when is_binary(ciphertext) do
    if can_decrypt?(ciphertext, opts) do
      key = Keyword.fetch!(opts, :key)
      %{remainder: <<iv::binary-16, ciphertext::binary>>} = Decoder.decode(ciphertext)
      state = do_init(key, iv, false)
      plaintext = do_decrypt(state, ciphertext)
      {:ok, plaintext}
    else
      :error
    end
  end

  @doc """
  Callback implementation for `Cloak.Cipher`. Determines if
  a ciphertext can be decrypted with this cipher.
  """
  @impl true
  def can_decrypt?(ciphertext, opts) when is_binary(ciphertext) do
    tag = Keyword.fetch!(opts, :tag)

    case Decoder.decode(ciphertext) do
      %{tag: ^tag, remainder: <<_iv::binary-16, _ciphertext::binary>>} ->
        true

      _other ->
        false
    end
  end

  # TODO: remove this once support for Erlang/OTP 21 is dropped
  defp do_init(key, iv, encoder?) do
    if System.otp_release() >= "22" do
      :crypto.crypto_init(:aes_ctr, key, iv, encoder?)
    else
      :crypto.stream_init(:aes_ctr, key, iv)
    end
  end

  defp do_encrypt(state, plaintext) do
    if System.otp_release() >= "22" do
      :crypto.crypto_update(state, plaintext)
    else
      {_state, cyphertext} = :crypto.stream_encrypt(state, plaintext)
      cyphertext
    end
  end

  defp do_decrypt(state, ciphertext) do
    if System.otp_release() >= "22" do
      :crypto.crypto_update(state, ciphertext)
    else
      {_state, plaintext} = :crypto.stream_decrypt(state, ciphertext)
      plaintext
    end
  end
end
