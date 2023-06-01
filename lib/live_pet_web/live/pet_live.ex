defmodule LivePetWeb.PetLive do
  use LivePetWeb, :live_view

  alias LivePet.Pets

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    pet = Pets.get_pet!(id)

    if connected?(socket) do
      register_for_updates(pet)
    end

    {:ok, assign_pet(socket, pet)}
  end

  defp register_for_updates(pet) do
    {:ok, _} = Registry.register(Registry.PetViewers, "pet-#{pet.id}", [])
  end

  @impl true
  def handle_info({:tick, pet}, socket) do
    {:noreply, assign_pet(socket, pet)}
  end

  defp assign_pet(socket, pet) do
    assign(socket, :pet, pet)
  end
end
