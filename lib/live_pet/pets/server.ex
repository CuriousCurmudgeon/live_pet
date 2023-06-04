defmodule LivePet.Pets.Server do
  @moduledoc """
  GenServer implementation of a pet. Updates the pet state on
  every tick and accepts messages to interact with it and get it's current
  state.
  """

  use GenServer
  alias LivePet.Pets

  @tick_length_in_milliseconds 5 * 1000

  ### Client process
  def start_link(pet) do
    GenServer.start_link(__MODULE__, pet)
  end

  ### Server process
  def init(pet) do
    {:ok, _} = Registry.register(Registry.Pets, pet.id, [])
    schedule_tick()
    {:ok, {pet}}
  end

  def handle_info(:tick, {pet}) do
    {:ok, pet} = Pets.update_pet(pet, %{age: pet.age + 1})

    Registry.dispatch(Registry.PetViewers, "pet-#{pet.id}", fn entries ->
      for {pid, _} <- entries, do: send(pid, {:tick, pet})
    end)

    schedule_tick()
    {:noreply, {pet}}
  end

  defp schedule_tick do
    Process.send_after(self(), :tick, @tick_length_in_milliseconds)
  end
end
