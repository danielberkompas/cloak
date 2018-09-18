defmodule Cloak.TestRepo.Migrations.CreatePosts do
  use Ecto.Migration

  def up do
    execute(~s{CREATE EXTENSION IF NOT EXISTS "uuid-ossp"})

    create table(:posts, primary_key: false) do
      add(:id, :uuid, primary_key: true, default: fragment("uuid_generate_v4()"))
      add(:title, :binary)
      timestamps(type: :utc_datetime)
    end

    create(index(:posts, [:id, :inserted_at]))
  end

  def down do
    drop(table(:posts))
    execute(~s{DROP EXTENSION "uuid-ossp"})
  end
end
