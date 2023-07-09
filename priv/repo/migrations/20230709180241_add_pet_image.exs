defmodule LivePet.Repo.Migrations.AddPetImage do
  use Ecto.Migration

  alias LivePet.Repo
  alias LivePet.Pets.Pet

  def change do
    alter table("pets") do
      add(:image, :string)
    end

    flush()

    Pet
    |> Repo.update_all(set: [image: "/images/pets/fox.jpg"])

    alter table("pets") do
      modify(:image, :string, null: false)
    end
  end
end
