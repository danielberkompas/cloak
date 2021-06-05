defmodule Cloak.Crypto do
  @moduledoc false
  # Interface for mapping encrypt/decrypt actions to different versions of Erlang's `:crypto` API.
  # See `Cloak.Crypto.Interface` for details on the included functions.

  @behaviour Cloak.Crypto.Interface

  @impl Cloak.Crypto.Interface
  def strong_rand_bytes(num) do
    :crypto.strong_rand_bytes(num)
  end

  if System.otp_release() >= "22" do
    @impl Cloak.Crypto.Interface
    def encrypt_one_time(cipher, key, iv, plaintext) do
      :crypto.crypto_one_time(cipher, key, iv, plaintext, encrypt: true)
    end

    @impl Cloak.Crypto.Interface
    def decrypt_one_time(cipher, key, iv, ciphertext) do
      :crypto.crypto_one_time(cipher, key, iv, ciphertext, encrypt: false)
    end

    @impl Cloak.Crypto.Interface
    def encrypt_one_time_aead(cipher, key, iv, aad, plaintext) do
      :crypto.crypto_one_time_aead(cipher, key, iv, plaintext, aad, true)
    end

    @impl Cloak.Crypto.Interface
    def decrypt_one_time_aead(cipher, key, iv, aad, ciphertext, ciphertag) do
      :crypto.crypto_one_time_aead(cipher, key, iv, ciphertext, aad, ciphertag, false)
    end

    @impl Cloak.Crypto.Interface
    def map_cipher(cipher), do: cipher
  else
    @impl Cloak.Crypto.Interface
    def encrypt_one_time(cipher, key, iv, plaintext) do
      state = :crypto.stream_init(cipher, key, iv)
      {_state, ciphertext} = :crypto.stream_encrypt(state, plaintext)
      ciphertext
    end

    @impl Cloak.Crypto.Interface
    def decrypt_one_time(cipher, key, iv, ciphertext) do
      state = :crypto.stream_init(cipher, key, iv)
      {_state, plaintext} = :crypto.stream_decrypt(state, ciphertext)
      plaintext
    end

    @impl Cloak.Crypto.Interface
    def encrypt_one_time_aead(cipher, key, iv, aad, plaintext) do
      :crypto.block_encrypt(cipher, key, iv, {aad, plaintext})
    end

    @impl Cloak.Crypto.Interface
    def decrypt_one_time_aead(cipher, key, iv, aad, ciphertext, ciphertag) do
      :crypto.block_decrypt(cipher, key, iv, {aad, ciphertext, ciphertag})
    end

    @impl Cloak.Crypto.Interface
    def map_cipher(:aes_256_gcm), do: :aes_gcm
    def map_cipher(:aes_256_ctr), do: :aes_ctr
    def map_cipher(cipher), do: cipher
  end
end
