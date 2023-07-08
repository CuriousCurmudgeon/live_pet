defmodule LivePetWeb.NewPetLive do
  use LivePetWeb, :live_view

  alias LivePet.Pets
  alias LivePet.Pets.Pet

  @impl true
  def mount(_params, _session, socket) do
    pet = %Pet{}
    changeset = Pets.change_pet(pet)
    {:ok, socket |> assign(:pet, pet) |> assign_form(changeset)}
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end
end
