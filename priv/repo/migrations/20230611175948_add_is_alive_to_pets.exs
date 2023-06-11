defmodule LivePet.Repo.Migrations.AddIsAliveToPets do
  use Ecto.Migration

  def change do
    alter table("pets") do
      add :is_alive, :boolean, default: true
    end
  end
end
