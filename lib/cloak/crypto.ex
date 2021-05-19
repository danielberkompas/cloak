defmodule Cloak.Crypto do
  @moduledoc ~S"""
  Interface for mapping encrypt/decrypt actions to different versions of Erlang's `:crypto` API
  """

  defmodule Interface do
  end

  def strong_rand_bytes(num) do
    :crypto.strong_rand_bytes(num)
  end

  if System.otp_release() >= "22" do
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
  end
end
