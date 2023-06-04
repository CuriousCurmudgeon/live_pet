defmodule LivePet.Pets.PetTest do
  use ExUnit.Case

  alias LivePet.Pets.Pet

  @valid_pet %Pet{age: 0, name: "Test", hunger: 0, user_id: 1}

  test "calculate_next_hunger increments hunger by 1" do
    assert Pet.calculate_next_hunger(@valid_pet) == 1
  end

  test "calculate_next_age increments age by 1" do
    assert Pet.calculate_next_age(@valid_pet) == 1
  end

  test "feed subtracts 100 from hunger with a floor of 0" do
    @valid_pet
    |> assert_hunger(0)
    |> Pet.feed()
    |> assert_hunger(0)
    |> update_hunger(50)
    |> Pet.feed()
    |> assert_hunger(0)
    |> update_hunger(101)
    |> Pet.feed()
    |> assert_hunger(1)
    |> update_hunger(200)
    |> Pet.feed()
    |> assert_hunger(100)
    |> update_hunger(201)
    |> Pet.feed()
    |> assert_hunger(101)
  end

  defp update_hunger(pet, hunger) do
    %{pet | hunger: hunger}
  end

  defp assert_hunger(pet, expected) do
    assert pet.hunger == expected
    pet
  end
end
