defmodule LivePetWeb.NewPetLive do
  use LivePetWeb, :live_view

  require Logger

  alias LivePet.Pets
  alias LivePet.Pets.Pet

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      Logger.info("In connected mount")
    else
      Logger.info("in disconnected mount")
    end
    changeset = Pets.change_pet(%Pet{})
    {:ok, socket |> assign_images() |> assign_selected_image(nil) |> assign_form(changeset)}
  end

  @impl true
  def handle_event("save", %{"pet" => pet_params}, socket) do
    pet_params = params_with_user_id(pet_params, socket)

    case Pets.create_pet(pet_params) do
      {:ok, pet} ->
        {:noreply,
         socket
         |> put_flash(:info, "Pet created successfully")
         |> push_navigate(to: ~p"/pet/#{pet.id}")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  def handle_event("validate", %{"pet" => pet_params}, socket) do
    changeset =
      %Pet{}
      |> Pets.change_pet(pet_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("select_image", %{"image" => image}, socket) do
    {:noreply, assign_selected_image(socket, image)}
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp assign_images(socket) do
    assign(socket, :images, Pets.list_pet_types() |> Enum.map(&pet_image_path/1))
  end

  defp assign_selected_image(socket, image) do
    assign(socket, :selected_image, image)
  end

  defp params_with_user_id(params, %{assigns: %{current_user: current_user}}) do
    params
    |> Map.put("user_id", current_user.id)
  end

  defp pet_image_path(type) do
    ~p"/images/pets/#{type <> ".jpg"}"
  end
end
