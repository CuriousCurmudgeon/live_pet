defmodule LivePetWeb.PetComponents do
  @moduledoc """
  Provides UI components for displaying a pet.
  """
  use Phoenix.Component
  use LivePetWeb, :verified_routes

  alias LivePet.Pets.Pet

  attr :hunger, :integer, required: true
  attr :class, :string, default: nil

  def hearts(assigns) do
    filled_hearts = Kernel.ceil((500 - assigns.hunger) / 100)

    assigns =
      assigns
      |> assign(:filled_hearts, filled_hearts)
      |> assign(:empty_hearts, 5 - filled_hearts)

    ~H"""
    <span class={@class}>
      <span :for={_ <- 1..@filled_hearts} :if={@filled_hearts > 0}>❤</span>
      <span :for={_ <- 1..@empty_hearts} :if={@empty_hearts > 0}>♡</span>
    </span>
    """
  end

  attr :pet, Pet, required: true

  def pet_card(assigns) do
    ~H"""
    <div class="flex flex-1 flex-col p-8">
      <img class="mx-auto h-32 w-32 flex-shrink-0" src={@pet.image} alt="" />
      <h3 class="mt-6 text-sm font-medium text-gray-900">
        {@pet.name} {if @pet.is_alive, do: "🆗", else: "☠️"}
      </h3>
      <dl class="mt-1 flex flex-grow flex-col justify-between">
        <dt class="sr-only">Birthday</dt>
        <dd class="text-sm text-gray-500">{Calendar.strftime(@pet.inserted_at, "%x")}</dd>
      </dl>
    </div>
    <div>
      <div class="-mt-px flex divide-x divide-gray-200">
        <div class="flex w-0 flex-1">
          <a
            href={~p"/pet/#{@pet.id}"}
            class="relative -mr-px inline-flex w-0 flex-1 items-center justify-center gap-x-3 rounded-bl-lg border border-transparent py-4 text-sm font-semibold text-gray-900 hover:bg-green-400"
          >
            View
          </a>
        </div>
      </div>
    </div>
    """
  end
end
