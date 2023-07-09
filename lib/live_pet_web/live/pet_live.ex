defmodule LivePetWeb.PetLive do
  use LivePetWeb, :live_view

  alias LivePet.Pets

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    # TODO: Make sure the logged in user owns the pet
    pet = Pets.Server.pet(id)

    {:ok, assign_pet(socket, pet)}
  end

  defp assign_pet(socket, pet) do
    assign(socket, :pet, pet)
  end
end
