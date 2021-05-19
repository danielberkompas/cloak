defmodule Cloak.Crypto do
  @moduledoc ~S"""
  Interface for mapping encrypt/decrypt actions to different versions of Erlang's `:crypto` API
  """

  defmodule Interface do
  end

  def strong_rand_bytes(num) do
    :crypto.strong_rand_bytes(num)
  end

  if System.otp_release() >= "24" do
    def encrypt_one_time(cipher, key, iv, plaintext) do
      :crypto.crypto_one_time(cipher, key, iv, plaintext, encrypt: true)
    end

    def decrypt_one_time(cipher, key, iv, plaintext) do
      :crypto.crypto_one_time(cipher, key, iv, plaintext, encrypt: false)
    end

    def encrypt_one_time_aead(cipher, key, iv, aad, plaintext) do
      :crypto.crypto_one_time_aead(cipher, key, iv, aad, plaintext, true)
    end

    def decrypt_one_time_aead(cipher, key, iv, aad, ciphertext, ciphertag) do
      :crypto.crypto_one_time_aead(cipher, key, iv, aad, ciphertext, ciphertag, false)
    end
  else
    def encrypt_one_time(cipher, key, iv, plaintext) do
      state = :crypto.stream_init(cipher, key, iv)
      {_state, ciphertext} = :crypto.stream_encrypt(state, plaintext)
      ciphertext
    end

    def decrypt_one_time(cipher, key, iv, ciphertext) do
      state = :crypto.stream_init(cipher, key, iv)
      {_state, plaintext} = :crypto.stream_decrypt(state, ciphertext)
      plaintext
    end

    def encrypt_one_time_aead(cipher, key, iv, aad, plaintext) do
      :crypto.block_encrypt(cipher, key, iv, {aad, plaintext})
    end

    def decrypt_one_time_aead(cipher, key, iv, aad, ciphertext, ciphertag) do
      :crypto.block_decrypt(cipher, key, iv, {aad, ciphertext, ciphertag})
    end
  end
end
