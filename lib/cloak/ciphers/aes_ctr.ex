defmodule Cloak.AES.CTR do
  @behaviour Cloak.Cipher

  # Module configuration
  @config Application.get_env(:cloak, __MODULE__)
  @keys   @config[:keys]
  @key    Enum.find(@keys, fn(key) -> key.default == true end)

  def encrypt(plaintext, key_tag \\ @key.tag) do
    key   = get_key(key_tag)
    iv    = :crypto.strong_rand_bytes(16)
    state = :crypto.stream_init(:aes_ctr, key.key, iv)

    {_state, ciphertext} = :crypto.stream_encrypt(state, to_string(plaintext))
    key.tag <> iv <> ciphertext
  end

  def decrypt(<<key_tag::binary-1, iv::binary-16, ciphertext::binary>>) do
    key   = get_key(key_tag)
    state = :crypto.stream_init(:aes_ctr, key.key, iv)

    {_state, plaintext} = :crypto.stream_decrypt(state, ciphertext)
    plaintext
  end

  def version do
    @key.tag
  end

  defp get_key(tag) do
    Enum.find(@keys, fn(key) -> key.tag == tag end)
  end
end
