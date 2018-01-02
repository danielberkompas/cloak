defmodule Cloak.AES.CTRTest do
  use ExUnit.Case
  import Cloak.AES.CTR

  doctest Cloak.AES.CTR

  test ".encrypt can encrypt a value" do
    assert encrypt("value") != "value"
  end

  test ".encrypt can encrypt a value with different keys" do
    assert encrypt("value", <<1>>) != encrypt("value", <<2>>)
  end

  test ".encrypt returns ciphertext in the format key_tag <> iv <> ciphertext" do
    assert <<1, iv::binary-16, ciphertext::binary>> = encrypt("value", <<1>>)
    assert byte_size(iv) == 16
    assert String.length(ciphertext) > 0
  end

  test ".encrypt can encrypt a value using an environment variable as key" do
    System.put_env("CLOAK_THIRD_KEY", "NhsNVkstdaUiXIh6fFZaRu+O6gK/p9C9LKJr3kkEWNA=")

    assert encrypt("value", <<3>>) != "value"
  end

  test ".encrypt can encrypt a value using an OTP environment variable as key" do
    encryption_key = <<
      54,
      27,
      13,
      86,
      75,
      45,
      117,
      165,
      34,
      92,
      136,
      122,
      124,
      86,
      90,
      70,
      239,
      142,
      234,
      2,
      191,
      167,
      208,
      189,
      44,
      162,
      107,
      222,
      73,
      4,
      88,
      208
    >>

    Application.put_env(:testapp, :encryption_key, encryption_key)

    assert encrypt("value", <<4>>) != "value"
  end

  test ".decrypt can decrypt a value" do
    assert encrypt("value") |> decrypt == "value"
  end

  test ".decrypt can decrypt a value encrypted with a non-default key" do
    assert encrypt("value", <<2>>) |> decrypt == "value"
  end
end
