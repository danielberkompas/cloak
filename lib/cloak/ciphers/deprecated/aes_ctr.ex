defmodule Cloak.Ciphers.Deprecated.AES.CTR do
  @moduledoc """
  DEPRECATED version of the `Cloak.Ciphers.AES.CTR` cipher, for use in
  migrating existing data to the new format used by `Cloak.Ciphers.AES.CTR`.

  ## Rationale

  The old `Cloak.AES.CTR` cipher used the following format for ciphertext:

      +---------------------------------------------------------+----------------------+
      |                         HEADER                          |         BODY         |
      +----------------------+------------------+---------------+----------------------+
      | Module Tag (n bytes) | Key Tag (1 byte) | IV (16 bytes) | Ciphertext (n bytes) |
      +----------------------+------------------+---------------+----------------------+

  The new `Cloak.Ciphers.AES.CTR` implementation no longer prepends the "Module Tag"
  component, and uses a new format as described in its docs. This cipher can
  assist in upgrading old ciphertext to the new format.

  See the [Upgrading from 0.6.x](0.6.x_to_0.7.x.html) guide for usage.
  """

  @behaviour Cloak.Cipher

  alias Cloak.Crypto

  @cipher Crypto.map_cipher(:aes_256_ctr)

  @deprecated "Use Cloak.Ciphers.AES.CTR.encrypt/2 instead. This call will raise an error."
  @impl Cloak.Cipher
  def encrypt(_plaintext, _opts) do
    raise RuntimeError,
          "#{inspect(__MODULE__)} is deprecated, and can only be used for decryption"
  end

  @impl Cloak.Cipher
  def decrypt(ciphertext, opts) do
    key = Keyword.fetch!(opts, :key)

    with true <- can_decrypt?(ciphertext, opts),
         <<iv::binary-16, ciphertext::binary>> <-
           String.replace_leading(ciphertext, tag(opts), <<>>) do
      plaintext = Crypto.decrypt_one_time(@cipher, key, iv, ciphertext)
      {:ok, plaintext}
    else
      _other ->
        :error
    end
  end

  @impl Cloak.Cipher
  def can_decrypt?(ciphertext, opts) do
    String.starts_with?(ciphertext, tag(opts))
  end

  defp tag(opts) do
    Keyword.fetch!(opts, :module_tag) <> Keyword.fetch!(opts, :tag)
  end
end
