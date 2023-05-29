defmodule LivePet.PetsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `LivePet.Pets` context.
  """

  @doc """
  Generate a pet.
  """
  def pet_fixture(attrs \\ %{}) do
    {:ok, pet} =
      attrs
      |> Enum.into(%{
        age: 42,
        name: "some name"
      })
      |> LivePet.Pets.create_pet()

    pet
  end
end
