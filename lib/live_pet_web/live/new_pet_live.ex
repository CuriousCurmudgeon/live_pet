defmodule LivePetWeb.NewPetLive do
  use LivePetWeb, :live_view

  require Logger

  alias LivePet.Pets
  alias LivePet.Pets.Pet

  @impl true
  def mount(_params, _session, socket) do
    changeset = Pets.change_pet(%Pet{})
    {:ok, socket |> assign_form(changeset)}
  end

  @impl true
  def handle_event("save", %{"pet" => pet_params}, socket) do
    pet_params = params_with_user_id(pet_params, socket)

    case Pets.create_pet(pet_params) do
      {:ok, _pet} ->
        {:noreply,
         socket
         |> put_flash(:info, "Pet created successfully")
         |> push_navigate(to: ~p"/pets")}

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
