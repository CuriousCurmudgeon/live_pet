defmodule LivePet.Pets.Server do
  @moduledoc """
  GenServer implementation of a pet. Updates the pet state on
  every tick and accepts messages to interact with it and get it's current
  state.
  """

  use GenServer
  alias LivePet.Pets
  alias LivePet.Pets.Pet

  @tick_length_in_milliseconds 5 * 1000

  ### Client process
  def start_link(pet) do
    GenServer.start_link(__MODULE__, pet)
  end

  def ping(pet) do
    # TODO: Error handling. We should find exactly one pet in the Registry
    Registry.lookup(Registry.Pets, pet.id)
    |> Enum.each(fn {pid, _} -> GenServer.cast(pid, {:ping}) end)
  end

  ### Server process
  def init(pet) do
    {:ok, _} = Registry.register(Registry.Pets, pet.id, [])
    schedule_tick()
    {:ok, {pet}}
  end

  def handle_info(:tick, {pet}) do
    {:ok, pet} =
      Pets.update_pet(pet, %{
        age: Pet.calculate_next_age(pet),
        hunger: Pet.calculate_next_hunger(pet)
      })

    Registry.dispatch(Registry.PetViewers, "pet-#{pet.id}", fn entries ->
      for {pid, _} <- entries, do: send(pid, {:tick, pet})
    end)

    schedule_tick()
    {:noreply, {pet}}
  end

  def handle_cast({:ping}, {pet}) do
    IO.puts("pinging pet #{pet.id}")
    {:noreply, {pet}}
  end

  defp schedule_tick do
    Process.send_after(self(), :tick, @tick_length_in_milliseconds)
  end
end
