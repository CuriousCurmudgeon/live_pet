defmodule LivePet.Pets.Pet do
  use Ecto.Schema
  import Ecto.Changeset

  schema "pets" do
    field :age, :integer, default: 0
    field :name, :string
    belongs_to :user, LivePet.Accounts.User

    timestamps()
  end

  @doc false
  def changeset(pet, attrs) do
    pet
    |> cast(attrs, [:name, :age, :user_id])
    |> validate_required([:name, :age, :user_id])
  end
end
