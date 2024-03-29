defmodule LivePet.Pets do
  @moduledoc """
  The Pets context.
  """

  import Ecto.Query, warn: false
  alias LivePet.PetSupervisor
  alias LivePet.Repo

  alias LivePet.Pets.Pet

  @doc """
  Returns a list of all pet types

  ## Examples

      iex> list_pet_types()
      ["cat", "crab", ...]

  """
  def list_pet_types do
    ["cat", "crab", "dog", "fish", "fox", "phoenix", "rabbit", "sea_turtle", "totoro"]
  end

  @doc """
  Returns the list of pets.

  ## Examples

      iex> list_pets()
      [%Pet{}, ...]

  """
  def list_pets do
    Repo.all(Pet)
  end

  @doc """
  List all the pets for the given user ordered by name

  ## Examples

      iex> list_pets()
      [%Pet{}, ...]
  """
  def list_pets_for_user(user) do
    Pet
    |> where([p], p.user_id == ^user.id)
    |> order_by(desc: :inserted_at)
    |> Repo.all()
  end

  def list_live_pets do
    Pet
    |> filter_live()
    |> Repo.all()
  end

  @doc """
  List up to limit pets that haven't been updated since the timestamp.
  """
  def list_stale_pets(updated_timestamp, limit) do
    Pet
    |> filter_live()
    |> where([p], p.updated_at < ^updated_timestamp)
    |> order_by([p], :updated_at)
    |> limit(^limit)
    |> Repo.all()
  end

  defp filter_live(query) do
    where(query, [p], p.is_alive)
  end

  @doc """
  Gets a single pet.

  Raises `Ecto.NoResultsError` if the Pet does not exist.

  ## Examples

      iex> get_pet!(123)
      %Pet{}

      iex> get_pet!(456)
      ** (Ecto.NoResultsError)

  """
  def get_pet!(id), do: Repo.get!(Pet, id)

  @doc """
  Gets a single pet.

  Returns nil if pet does not exist

  ## Examples

      iex> get_pet(123)
      %Pet{}

      iex> get_pet(456)
      nil

  """
  def get_pet(id), do: Repo.get(Pet, id)

  @doc """
  Creates a pet.

  ## Examples

      iex> create_pet(%{field: value})
      {:ok, %Pet{}}

      iex> create_pet(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_pet(attrs \\ %{}) do
    %Pet{}
    |> Pet.changeset(attrs)
    |> Repo.insert()
    |> maybe_start_pet_server()
  end

  defp maybe_start_pet_server({:ok, pet} = result) do
    PetSupervisor.start_pet_server(pet)
    result
  end

  defp maybe_start_pet_server({:error, _} = result), do: result

  @doc """
  Updates a pet.

  ## Examples

      iex> update_pet(pet, %{field: new_value})
      {:ok, %Pet{}}

      iex> update_pet(pet, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_pet(%Pet{} = pet, attrs) do
    pet
    |> Pet.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a pet.

  ## Examples

      iex> delete_pet(pet)
      {:ok, %Pet{}}

      iex> delete_pet(pet)
      {:error, %Ecto.Changeset{}}

  """
  def delete_pet(%Pet{} = pet) do
    Repo.delete(pet)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking pet changes.

  ## Examples

      iex> change_pet(pet)
      %Ecto.Changeset{data: %Pet{}}

  """
  def change_pet(%Pet{} = pet, attrs \\ %{}) do
    Pet.changeset(pet, attrs)
  end
end
