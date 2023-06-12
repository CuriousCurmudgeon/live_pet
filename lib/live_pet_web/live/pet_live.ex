defmodule LivePetWeb.PetLive do
  use LivePetWeb, :live_view

  alias LivePet.Pets

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    # TODO: Make sure the logged in user owns the pet
    # TODO: If the pet is dead, then we won't get able to get the changeset
    pet =
      Pets.Server.changeset(id)
      |> Ecto.Changeset.apply_changes()

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

  @impl true
  def handle_event("ping", _, %{assigns: %{pet: pet}} = socket) do
    Pets.Server.ping(pet.id)
    {:noreply, socket}
  end

  def handle_event("feed", _, %{assigns: %{pet: pet}} = socket) do
    pet = Pets.Server.feed(pet.id)

    {:noreply, assign_pet(socket, pet)}
  end

  defp assign_pet(socket, pet) do
    assign(socket, :pet, pet)
  end
end
