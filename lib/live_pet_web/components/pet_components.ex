defmodule LivePetWeb.PetComponents do
  @moduledoc """
  Provides UI components for displaying a pet.
  """
  use Phoenix.Component

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
end
