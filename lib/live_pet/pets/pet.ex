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
  Increment the hunger for the pet represented by the changeset.
  """
  def increment_hunger(%Ecto.Changeset{} = changeset) do
    {_, current_hunger} = Ecto.Changeset.fetch_field(changeset, :hunger)

    Ecto.Changeset.put_change(changeset, :hunger, current_hunger + 1)
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
  def feed(%Ecto.Changeset{} = changeset) do
    {_, current_hunger} = Ecto.Changeset.fetch_field(changeset, :hunger)

    Ecto.Changeset.put_change(changeset, :hunger, Kernel.max(current_hunger - 100, 0))
  end
end
