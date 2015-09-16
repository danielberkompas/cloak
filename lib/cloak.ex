defmodule Cloak do
  {cipher, config} = Cloak.Config.default_cipher
  @cipher cipher
  @tag config[:tag]

  def encrypt(plaintext) do
    @tag <> @cipher.encrypt(plaintext)
  end

  for {cipher, config} <- Cloak.Config.all do
    def decrypt(unquote(config[:tag]) <> ciphertext) do
      unquote(cipher).decrypt(ciphertext)
    end
  end
  def decrypt(invalid) do
    raise ArgumentError, "No cipher found to decrypt #{inspect invalid}."
  end

  def version do
    @tag <> @cipher.version
  end
end
