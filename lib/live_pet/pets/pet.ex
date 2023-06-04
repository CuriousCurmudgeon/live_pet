defmodule LivePet.Pets.Pet do
  use Ecto.Schema
  import Ecto.Changeset

  schema "pets" do
    field :age, :integer, default: 0
    field :name, :string
    field :hunger, :integer, default: 0
    belongs_to :user, LivePet.Accounts.User

    timestamps()
  end

  @doc false
  def changeset(pet, attrs) do
    pet
    |> cast(attrs, [:name, :age, :hunger, :user_id])
    |> validate_required([:name, :age, :hunger, :user_id])
    |> validate_number(:hunger, greater_than_or_equal_to: 0)
  end
end
