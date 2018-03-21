defmodule Cloak.TestUser do
  use Ecto.Schema

  schema "users" do
    field(:name, :string)
    field(:email, Cloak.Test.Encrypted.Binary)
    field(:email_hash, Cloak.Test.Hashed.HMAC)
  end
end
