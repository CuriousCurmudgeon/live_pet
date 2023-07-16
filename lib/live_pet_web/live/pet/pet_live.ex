defmodule LivePetWeb.Pet.PetLive do
  use LivePetWeb, :live_view

  alias LivePet.Pets
  alias LivePet.Pets.Pet
  alias LivePetWeb.Presence

  @impl true
  def mount(%{"id" => pet_id}, _session, socket) do
    current_user_id = socket.assigns.current_user.id

    case Pets.Simulation.get_pet(pet_id) do
      # Current user owns pet
      {:ok, %Pet{user_id: ^current_user_id} = pet} ->
        if connected?(socket) do
          register_for_updates(pet)
        end

        {:ok,
         socket
         |> assign_pet_id(pet_id)
         |> assign_pet(pet)
         |> assign(:active_pets_component_id, "active-pets")}

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
  def handle_params(_params, _uri, socket) do
    maybe_track_pet(socket)
    {:noreply, socket}
  end

  @impl true
  def handle_info({:update, pet}, socket) do
    untrack_or_update_pet(pet)
    {:noreply, assign_pet(socket, pet)}
  end

  @impl true
  def handle_event("feed", _, %{assigns: %{pet: pet}} = socket) do
    Pets.Simulation.feed(pet.id)

    {:noreply, socket}
  end

  def handle_event("camping_request", %{"pet_id" => pet_id}, socket) do
    IO.inspect(pet_id)
    {:noreply, socket}
  end

  defp register_for_updates(pet) do
    {:ok, _} = Registry.register(Registry.PetViewers, "pet-#{pet.id}", [])
  end

  defp maybe_track_pet(%{assigns: %{pet: %Pet{is_alive: true} = pet}} = socket) do
    if connected?(socket) do
      Presence.track_pet(self(), pet)
    end
  end

  defp maybe_track_pet(_socket), do: nil

  defp untrack_or_update_pet(%Pet{is_alive: false} = pet) do
    Presence.untrack_pet(self(), pet)
  end

  defp untrack_or_update_pet(%Pet{} = pet) do
    Presence.update_pet(self(), pet)
  end

  defp assign_pet_id(socket, pet_id) do
    # We do this because we don't want the active pets live component to update every time
    # we get new pet state. We just want to pass the pet_id through and have it never change.
    assign(socket, :pet_id, Integer.parse(pet_id) |> elem(0))
  end

  defp assign_pet(socket, pet) do
    assign(socket, :pet, pet)
  end
end
