defmodule LivePetWeb.Pet.ActivePetsLive do
  use LivePetWeb, :live_component
  alias LivePetWeb.Presence

  @impl true
  def update(assigns, socket) do
    {:ok, socket |> assign_active_pets(assigns.pet_id)}
  end

  defp assign_active_pets(socket, pet_id) do
    assign(
      socket,
      :active_pets,
      Presence.list_active_pets() |> Enum.filter(fn x -> x.id != pet_id end)
    )
  end
end
