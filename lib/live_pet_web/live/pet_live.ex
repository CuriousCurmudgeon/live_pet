defmodule LivePetWeb.PetLive do
  use LivePetWeb, :live_view

  alias LivePet.Pets
  alias LivePet.Pets.Pet

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    current_user_id = socket.assigns.current_user.id

    case Pets.Simulation.get_pet(id) do
      # Current user owns pet
      {:ok, %Pet{user_id: ^current_user_id} = pet} ->
        if connected?(socket) do
          register_for_updates(pet)
        end

        {:ok, assign_pet(socket, pet)}

      # Current user does not own pet
      {:ok, _} ->
        {:ok,
         socket
         |> put_flash(:error, "You do not have permission to view that pet")
         |> redirect(to: ~p"/pets")}

      {:error, :dead, %Pet{} = pet} ->
        {:ok, assign_pet(socket, pet)}

      # The pet server was not found
      {:error, :not_found} ->
        {:ok,
         socket
         |> put_flash(:error, "Pet not found")
         |> redirect(to: ~p"/pets")}
    end
  end

  @impl true
  def handle_info({:update, pet}, socket) do
    {:noreply, assign_pet(socket, pet)}
  end

  @impl true
  def handle_event("feed", _, %{assigns: %{pet: pet}} = socket) do
    Pets.Simulation.feed(pet.id)

    {:noreply, socket}
  end

  defp register_for_updates(pet) do
    {:ok, _} = Registry.register(Registry.PetViewers, "pet-#{pet.id}", [])
  end

  defp assign_pet(socket, pet) do
    assign(socket, :pet, pet)
  end
end
