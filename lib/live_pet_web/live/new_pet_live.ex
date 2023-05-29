defmodule LivePetWeb.NewPetLive do
  use LivePetWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, socket}
  end
end
