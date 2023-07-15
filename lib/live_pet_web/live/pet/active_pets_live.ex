defmodule LivePetWeb.Pet.ActivePetsLive do
  use LivePetWeb, :live_component
  alias LivePetWeb.Presence

  def update(_assigns, socket) do
    {:ok, socket}
  end
end
