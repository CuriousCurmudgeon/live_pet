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
    lookup_pid(pet)
    |> GenServer.cast({:ping})
  end

  def feed(pet) do
    lookup_pid(pet)
    |> GenServer.call(:feed)
  end

  defp lookup_pid(pet) do
    # TODO: Error handling. We should find exactly one pet in the Registry
    Registry.lookup(Registry.Pets, pet.id)
    |> List.first()
    |> elem(0)
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

  def handle_call(:feed, _, {pet}) do
    {:ok, pet} = Pets.update_pet(pet, Map.from_struct(Pet.feed(pet)))
    {:reply, pet, {pet}}
  end

  def handle_cast({:ping}, {pet}) do
    {:noreply, {pet}}
  end

  defp schedule_tick do
    Process.send_after(self(), :tick, @tick_length_in_milliseconds)
  end
end
