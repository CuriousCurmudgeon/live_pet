defmodule LivePet.Pets.Pet do
  use Ecto.Schema
  import Ecto.Changeset

  schema "pets" do
    field :age, :integer, default: 0
    field :name, :string
    field :user_id, :id

    timestamps()
  end

  @doc false
  def changeset(pet, attrs) do
    pet
    |> cast(attrs, [:name, :age])
    |> validate_required([:name, :age])
  end
end
