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

  @impl true
  def handle_event("validate", %{"pet" => pet_params}, socket) do
    changeset =
      socket.assigns.pet
      |> Pets.change_pet(pet_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"pet" => pet_params}, socket) do
    pet_params = params_with_user_id(pet_params, socket)

    case Pets.create_pet(pet_params) do
      {:ok, pet} ->
        {:noreply,
         socket
         |> put_flash(:info, "Pet created successfully")
         |> push_navigate(to: ~p"/pets/#{pet.id}")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp params_with_user_id(params, %{assigns: %{current_user: current_user}}) do
    params
    |> Map.put("user_id", current_user.id)
  end
end
