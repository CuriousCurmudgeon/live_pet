defmodule LivePetWeb.PetLive do
  use LivePetWeb, :live_view

  alias LivePet.Pets

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    pet = Pets.get_pet!(id)
    {:ok, socket |> assign(:pet, pet)}
  end
end
