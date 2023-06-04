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
end
