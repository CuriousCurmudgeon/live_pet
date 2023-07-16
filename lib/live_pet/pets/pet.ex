defmodule LivePet.Pets.Pet do
  use Ecto.Schema
  import Ecto.Changeset

  schema "pets" do
    field :name, :string
    field :image, :string
    field :age, :integer, default: 0
    field :hunger, :integer, default: 250
    field :is_alive, :boolean, default: true
    belongs_to :user, LivePet.Accounts.User

    timestamps()
  end

  @doc false
  def changeset(pet, attrs) do
    pet
    |> cast(attrs, [:name, :image, :age, :hunger, :user_id, :is_alive])
    |> validate_required([:name, :age, :hunger, :user_id])
    |> validate_required([:image], message: "Please choose an image")
    |> validate_length(:name, min: 3, max: 100)
    |> validate_number(:hunger, greater_than_or_equal_to: 0)
  end

  @doc """
  Increment the hunger for the pet represented by the changeset.
  """
  def increment_hunger(%Ecto.Changeset{} = changeset) do
    {_, current_hunger} = Ecto.Changeset.fetch_field(changeset, :hunger)

    Ecto.Changeset.put_change(changeset, :hunger, Kernel.min(current_hunger + 5, 500))
  end

  @doc """
  Increment the age for the pet represented by the changeset.
  """
  def increment_age(%Ecto.Changeset{} = changeset) do
    {_, current_age} = Ecto.Changeset.fetch_field(changeset, :age)

    Ecto.Changeset.put_change(changeset, :age, current_age + 1)
  end

  @doc """
  Should the pet repsented by the changeset die now?
  """
  def die?(%Ecto.Changeset{} = changeset) do
    {_, current_age} = Ecto.Changeset.fetch_field(changeset, :age)
    current_age > 10_000
  end

  @doc """
  Feed the pet represented by the changeset and return an updated changeset
  """
  def feed(%Ecto.Changeset{} = changeset, type) do
    {_, current_hunger} = Ecto.Changeset.fetch_field(changeset, :hunger)
    stats = get_food_type_stats(type)

    Ecto.Changeset.put_change(changeset, :hunger, Kernel.max(current_hunger - stats.hunger, 0))
  end

  defp get_food_type_stats(type) do
    %{normal: %{hunger: 100}, treat: %{hunger: 10}}
    |> Map.get(type)
  end
end
