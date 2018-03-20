defmodule Cloak.Cipher.Deprecated.AES.GCM do
  @moduledoc """
  DEPRECATED version of the `Cloak.Cipher.AES.GCM` cipher, for use in
  migrating existing data to the new format used by `Cloak.Cipher.AES.GCM`.

  ## Rationale

  The old `Cloak.AES.GCM` cipher used the following format for ciphertext:

      +---------------------------------------------------------+----------------------+
      |                         HEADER                          |         BODY         |
      +----------------------+------------------+---------------+----------------------+
      | Module Tag (n bytes) | Key Tag (1 byte) | IV (16 bytes) | Ciphertext (n bytes) |
      +----------------------+------------------+---------------+----------------------+

  The new `Cloak.Cipher.AES.GCM` implementation no longer prepends the "Module Tag"
  component, and uses a new format as described in its docs. This cipher can
  assist in upgrading old ciphertext to the new format.

  See the [Upgrading from 0.6.x](0.6.x_to_0.7.x.html) guide for usage.
  """

  @behaviour Cloak.Cipher
  @aad "AES256GCM"

  alias Cloak.Tags.Decoder

  @deprecated "Use Cloak.Cipher.AES.GCM.encrypt/2 instead. This call will raise an error."
  @impl Cloak.Cipher
  def encrypt(_plaintext, _opts) do
    raise RuntimeError,
          "#{inspect(__MODULE__)} is deprecated, and can only be used for decryption"
  end

  @impl Cloak.Cipher
  def decrypt(ciphertext, opts) do
    key = Keyword.fetch!(opts, :key)

    with <<iv::binary-16, ciphertag::binary-16, ciphertext::binary>> <- decode(ciphertext, opts) do
      {:ok, :crypto.block_decrypt(:aes_gcm, key, iv, {@aad, ciphertext, ciphertag})}
    else
      _other ->
        :error
    end
  end

  @impl Cloak.Cipher
  def can_decrypt?(ciphertext, opts) do
    case decode(ciphertext, opts) do
      remainder when is_binary(remainder) ->
        true

      _other ->
        false
    end
  end

  @impl Cloak.Cipher
  def version(opts) do
    Keyword.fetch!(opts, :tag)
  end

  defp decode(ciphertext, opts) do
    module_tag = Keyword.fetch!(opts, :module_tag)
    tag = Keyword.fetch!(opts, :tag)

    result =
      ciphertext
      |> String.replace_leading(module_tag, <<>>)
      |> Decoder.decode()

    case result do
      %{
        tag: ^tag,
        remainder: <<_iv::binary-16, _ciphertag::binary-16, _ciphertext::binary>> = remainder
      } ->
        remainder

      _other ->
        :error
    end
  end
end
