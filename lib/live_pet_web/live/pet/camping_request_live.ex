defmodule LivePetWeb.Pet.CampingRequestLive do
  use LivePetWeb, :live_component

  @impl true
  def update(assigns, socket) do
    {:ok, socket |> assign_state(assigns.state)}
  end

  defp assign_state(socket, state) do
    assign(socket, :state, state)
  end
end
