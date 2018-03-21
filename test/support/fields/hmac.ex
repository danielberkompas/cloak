defmodule Cloak.Test.Hashed.HMAC do
  use Cloak.Fields.HMAC, otp_app: :cloak

  def init(_config) do
    {:ok,
     [
       algorithm: :sha512,
       secret: "secret"
     ]}
  end
end
