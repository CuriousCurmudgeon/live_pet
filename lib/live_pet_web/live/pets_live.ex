defmodule LivePetWeb.PetsLive do
  use LivePetWeb, :live_view

  alias LivePet.Pets

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign_pets(socket)}
  end

  defp assign_pets(socket) do
    user = socket.assigns.current_user

    assign(socket, :pets, Pets.list_pets_for_user(user))
  end
end
