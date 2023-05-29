defmodule LivePetWeb.PetLive do
  use LivePetWeb, :live_view

  alias LivePet.Pets

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    pet = Pets.get_pet!(id)

    if connected?(socket) do
      start_pet_server(socket, pet)
    end

    {:ok, socket |> assign(:pet, pet)}
  end

  defp start_pet_server(socket, pet) do
    socket
    |> assign(
      :server_id,
      LivePet.Pets.Server.start_link(pet)
    )
  end
end
