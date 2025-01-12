defmodule LivePetWeb.Pet.ActivePetsLive do
  use LivePetWeb, :live_component

  require Logger
  alias LivePet.{Accounts, Pets, PubSub}
  alias LivePetWeb.Presence

  @impl true
  def update(assigns, socket) do
    {:ok,
     socket
     |> assign_active_pets(assigns.pet_id)
     |> assign_available_treats(assigns.available_treats)
     |> assign_user(assigns.user)}
  end

  @impl true
  def handle_event("give_treat", %{"pet_id" => recipient_pet_id}, socket) do
    user_id = socket.assigns.user.id

    socket =
      case Accounts.give_treat(Accounts.get_user!(user_id)) do
        {:ok, user} ->
          Logger.info("User #{user_id} is giving a treat to pet #{recipient_pet_id}")
          Pets.Simulation.feed(recipient_pet_id, :treat)

          PubSub.broadcast_user_available_treats(user)

          socket

        {:error, error} ->
          Logger.error("Error giving treat: #{inspect(error)}")

          socket
          |> put_flash(:error, "Error giving treat")
      end

    {:noreply, socket}
  end

  defp assign_active_pets(socket, pet_id) do
    assign(
      socket,
      :active_pets,
      Presence.list_active_pets()
      |> Enum.filter(fn x -> x.id != pet_id end)
      |> Enum.sort_by(fn x -> x.name end)
    )
  end

  defp assign_available_treats(socket, available_treats) do
    assign(socket, :available_treats, available_treats)
  end

  defp assign_user(socket, user) do
    assign(socket, :user, user)
  end
end
