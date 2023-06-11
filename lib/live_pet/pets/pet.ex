defmodule LivePet.Pets.Pet do
  use Ecto.Schema
  import Ecto.Changeset

  schema "pets" do
    field :age, :integer, default: 0
    field :name, :string
    field :hunger, :integer, default: 0
    field :is_alive, :boolean, default: true
    belongs_to :user, LivePet.Accounts.User

    timestamps()
  end

  @doc false
  def changeset(pet, attrs) do
    pet
    |> cast(attrs, [:name, :age, :hunger, :user_id, :is_alive])
    |> validate_required([:name, :age, :hunger, :user_id])
    |> validate_number(:hunger, greater_than_or_equal_to: 0)
  end

  @doc """
  Calculate the pet's next hunger. Typically, this will be called on
  every tick.
  """
  def calculate_next_hunger(pet) do
    pet.hunger + 1
  end

  @doc """
  Calculate the pet's next age. Typically, this will be called on
  every tick.
  """
  def calculate_next_age(pet) do
    pet.age + 1
  end

  @doc """
  Should this pet die now?
  """
  def die?(pet) do
    pet.age > 10_000
  end

  def feed(pet) do
    %{pet | hunger: Kernel.max(pet.hunger - 100, 0)}
  end
end
