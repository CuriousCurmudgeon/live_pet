defmodule LivePetWeb.Pet.PetLive do
  use LivePetWeb, :live_view

  require Logger
  alias LivePet.Pets
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
      |> assign_camping_state(:none)

    case Pets.Simulation.get_pet(pet_id) do
      # Current user owns pet
      {:ok, %Pet{user_id: ^current_user_id} = pet} ->
        if connected?(socket) do
          register_for_updates(pet)
          Endpoint.subscribe(@active_pets_topic)
          Endpoint.subscribe(pet_topic(pet.id))
        end

        {:ok,
         socket
         |> assign_pet(pet)
         |> assign(:active_pets_component_id, "active-pets")
         |> assign(:camping_request_component_id, "camping-request")}

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
    maybe_untrack_pet(pet)
    {:noreply, assign_pet(socket, pet)}
  end

  def handle_info(
        %{event: "camping_request", payload: %{pet_id: requesting_pet_id}} = message,
        socket
      ) do
    Logger.info("Received camping request from #{requesting_pet_id}")
    {:noreply, assign_camping_state(socket, :responding)}
  end

  def handle_info(%{event: "presence_diff", topic: @active_pets_topic}, socket) do
    send_update(ActivePetsLive,
      id: socket.assigns.active_pets_component_id,
      pet_id: socket.assigns.pet_id
    )

    {:noreply, socket}
  end

  @impl true
  def handle_event("feed", _, %{assigns: %{pet: pet}} = socket) do
    Pets.Simulation.feed(pet.id)

    {:noreply, socket}
  end

  def handle_event("go_camping", %{"pet_id" => other_pet_id}, %{assigns: %{pet: pet}} = socket) do
    Endpoint.broadcast(pet_topic(other_pet_id), "camping_request", %{pet_id: pet.id})
    {:noreply, socket |> assign_camping_state(:requesting)}
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

  defp assign_camping_state(socket, state) do
    assign(socket, :camping_state, state)
  end

  defp pet_topic(pet_id) do
    "pet:#{pet_id}"
  end
end
