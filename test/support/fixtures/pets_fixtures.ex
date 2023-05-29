defmodule LivePet.PetsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `LivePet.Pets` context.
  """

  import LivePet.AccountsFixtures

  @doc """
  Generate a pet.
  """
  def pet_fixture(attrs \\ %{}) do
    {:ok, pet} =
      attrs
      |> Enum.into(%{
        age: 0,
        name: "some name",
        user_id: user_fixture().id
      })
      |> LivePet.Pets.create_pet()

    pet
  end
end
