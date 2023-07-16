defmodule LivePet.Repo.Migrations.AddTreatsToUsers do
  use Ecto.Migration

  def change do
    alter table("users") do
      add(:available_treats, :integer, null: false, default: 5)
    end
  end
end
