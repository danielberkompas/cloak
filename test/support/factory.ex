defmodule Cloak.Factory do
  def create_user(email) do
    email = Cloak.TestVault.encrypt!(email, :secondary)
    {:ok, email_hash} = Cloak.Test.Hashed.HMAC.dump(email)

    {_count, [user]} =
      Cloak.TestRepo.insert_all(
        "users",
        [
          %{
            name: "John Smith",
            email: email,
            email_hash: email_hash,
            inserted_at: DateTime.utc_now(),
            updated_at: DateTime.utc_now()
          }
        ],
        returning: [:id, :name, :email, :email_hash]
      )

    user
  end
end
