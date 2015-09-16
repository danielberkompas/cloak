defmodule CloakTest do
  use ExUnit.Case
  import Cloak

  doctest Cloak

  test ".encrypt can encrypt a value" do
    assert encrypt("value") != "value"
  end

  test ".encrypt prepends the cipher tag to the ciphertext" do
    assert <<"AES", _ciphertext::binary>> = encrypt("value")
  end

  test ".decrypt can decrypt a value" do
    assert encrypt("value") |> decrypt == "value"
  end

  test ".decrypt can decrypt a value encrypted by a non-default encryptor" do
  end

  test ".version returns the default cipher tag joined with the cipher.version" do
    assert <<"AES", 1>> = version
  end
end
