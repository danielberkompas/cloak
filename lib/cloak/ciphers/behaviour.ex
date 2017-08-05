defmodule Cloak.Cipher do
  @moduledoc """
  A behaviour for encryption/decryption modules. Use it to write your own custom
  Cloak-compatible cipher modules.

  ## Example

  Here's a sample custom cipher that adds "Hello, " to the start of every
  ciphertext, and removes it on decryption.

      defmodule MyCustomCipher do
        @behaviour Cloak.Cipher

        def encrypt(plaintext) do
          "Hello, #\{to_string(plaintext)\}"
        end

        def decrypt("Hello, " <> plaintext) do
          plaintext
        end

        def version do
          "hello"
        end
      end

  As long as you implement the 3 callbacks below, everything should work
  smoothly.

  ## Configuration

  Your custom cipher will be responsible for reading any custom configuration
  that it requires from the `:cloak` application configuration.

  For example, suppose we wanted to make the word "Hello" in the custom cipher
  above configurable. We could add it to the `config.exs`:

      config :cloak, MyCustomCipher,
        default: true,
        tag: "custom",
        word: "Cheerio"

  And then read it in our cipher:

      defmodule MyCustomCipher do
        @behaviour Cloak.Cipher
        @word Application.get_env(:cloak, __MODULE__)[:word]

        def encrypt(plaintext) do
          "#\{@word\}, #\{to_string(plaintext)\}"
        end

        def decrypt(@word <> ", " <> plaintext) do
          plaintext
        end

        def version do
          @word
        end
      end
  """

  @doc """
  Encrypt a value. Your function should include any information it will need for
  decryption with the output.
  """
  @callback encrypt(any) :: String.t

  @doc """
  Decrypt a value.
  """
  @callback decrypt(String.t) :: String.t

  @doc """
  Must return a string representing the default settings of your module as it is
  currently configured.

  This will be used by `Cloak.version/0` to generate a unique tag, which can
  then be stored on each database table row to track which encryption
  configuration it is currently encrypted with.
  """
  @callback version :: String.t
end
