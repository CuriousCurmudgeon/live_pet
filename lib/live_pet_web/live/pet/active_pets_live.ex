defmodule LivePetWeb.Pet.ActivePetsLive do
  use LivePetWeb, :live_component
  alias LivePetWeb.Presence

  @impl true
  def update(assigns, socket) do
    {:ok, socket |> assign_pet(assigns.pet) |> assign_active_pets()}
  end

  defp assign_pet(socket, pet) do
    assign(socket, :pet, pet)
  end

  defp assign_active_pets(%{assigns: %{pet: pet}} = socket) do
    assign(
      socket,
      :active_pets,
      Presence.list_active_pets() |> Enum.filter(fn x -> x.id != pet.id end)
    )
  end
end
