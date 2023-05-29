defmodule LivePet.Repo.Migrations.CreatePets do
  use Ecto.Migration

  def change do
    create table(:pets) do
      add :name, :string
      add :age, :integer
      add :user_id, references(:users, on_delete: :nothing)

      timestamps()
    end

    create index(:pets, [:user_id])
  end
end
