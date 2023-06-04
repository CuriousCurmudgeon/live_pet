defmodule LivePet.Repo.Migrations.AddPetHunger do
  use Ecto.Migration

  def change do
    alter table("pets") do
      add :hunger, :integer, default: 0
    end
  end
end
