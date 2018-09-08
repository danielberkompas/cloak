defmodule Cloak.TestRepo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add(:name, :string)
      add(:email, :binary)
      add(:email_hash, :binary)

      timestamps(type: :utc_datetime)
    end

    create(index(:users, [:inserted_at]))
  end
end
