defmodule LivePetWeb.PetLive do
  use LivePetWeb, :live_view

  alias LivePet.Pets
  alias LivePet.Pets.Pet

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    current_user_id = socket.assigns.current_user.id

    case Pets.Server.pet(id) do
      %Pet{user_id: ^current_user_id} = pet ->
        {:ok, assign_pet(socket, pet)}

      _ ->
        {:ok,
         socket
         |> put_flash(:error, "You do not have permission to view that pet")
         |> redirect(to: ~p"/pets")}
    end
  end

  defp assign_pet(socket, pet) do
    assign(socket, :pet, pet)
  end
end
