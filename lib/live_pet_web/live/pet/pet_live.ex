defmodule LivePetWeb.Pet.PetLive do
  use LivePetWeb, :live_view

  require Logger
  alias LivePet.{Accounts, Pets}
  alias LivePet.Pets.Pet
  alias LivePetWeb.Pet.ActivePetsLive
  alias LivePetWeb.{Endpoint, Presence}

  @active_pets_topic "active_pets"

  @impl true
  def mount(%{"id" => pet_id}, _session, socket) do
    current_user_id = socket.assigns.current_user.id

    socket =
      socket
      |> assign_pet_id(pet_id)

    case Pets.Simulation.get_pet(pet_id) do
      # Current user owns pet
      {:ok, %Pet{user_id: ^current_user_id} = pet} ->
        if connected?(socket) do
          register_for_updates(pet)
          Endpoint.subscribe(@active_pets_topic)
          Endpoint.user_topic(current_user_id) |> Endpoint.subscribe()
          Presence.track_pet(self(), pet)
        end

        {:ok,
         socket
         |> assign_pet(pet)
         |> assign(:active_pets_component_id, "active-pets")
         |> assign_available_treats(Accounts.get_user!(current_user_id).available_treats)}

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
    maybe_untrack_pet(pet)
    {:noreply, assign_pet(socket, pet)}
  end

  def handle_info(
        %{event: "available_treats", payload: %{available_treats: available_treats}},
        socket
      ) do
    socket = assign_available_treats(socket, available_treats)
    {:noreply, socket}
  end

  def handle_info(%{event: "presence_diff", topic: @active_pets_topic}, socket) do
    current_user = socket.assigns.current_user

    send_update(ActivePetsLive,
      id: socket.assigns.active_pets_component_id,
      pet_id: socket.assigns.pet_id,
      available_treats: current_user.available_treats,
      user: current_user
    )

    {:noreply, socket}
  end

  @impl true
  def handle_event("feed", _, %{assigns: %{pet: pet}} = socket) do
    Pets.Simulation.feed(pet.id, :normal)

    {:noreply, socket}
  end

  defp register_for_updates(pet) do
    {:ok, _} = Registry.register(Registry.PetViewers, "pet-#{pet.id}", [])
  end

  defp maybe_untrack_pet(%Pet{is_alive: false}) do
    Presence.untrack_pet(self())
  end

  defp maybe_untrack_pet(_), do: nil

  defp assign_pet_id(socket, pet_id) do
    # We do this because we don't want the active pets live component to update every time
    # we get new pet state. We just want to pass the pet_id through and have it never change.
    assign(socket, :pet_id, Integer.parse(pet_id) |> elem(0))
  end

  defp assign_pet(socket, pet) do
    assign(socket, :pet, pet)
  end

  defp assign_available_treats(socket, available_treats) do
    assign(socket, :available_treats, available_treats)
  end
end
