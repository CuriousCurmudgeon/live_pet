defmodule LivePet.Pets.Server do
  @moduledoc """
  GenServer implementation of a pet. Updates the pet state on
  every tick and accepts messages to interact with it and get it's current
  state.
  """

  use GenServer, restart: :transient
  require Logger
  alias LivePet.Pets
  alias LivePet.Pets.Pet

  @tick_length_in_milliseconds 5 * 1000

  ### Client process
  def start_link(pet) do
    GenServer.start_link(__MODULE__, pet, name: get_process_name(pet))
  end

  @doc """
  Get the current state of the pet.
  """
  def get(pet) do
    GenServer.call(get_process_name(pet), :get)
  end

  def ping(pet) do
    GenServer.cast(get_process_name(pet), {:ping})
  end

  def feed(pet) do
    GenServer.call(get_process_name(pet), :feed)
  end

  defp get_process_name(pet) do
    {:via, :global, "pet-#{pet.id}"}
  end

  ### Server process
  def init(pet) do
    Logger.info("Starting pet #{pet.id}")
    schedule_tick()
    {:ok, {pet}}
  end

  def handle_info(:tick, {pet}) do
    schedule_tick()
    pet = %{pet | age: Pet.calculate_next_age(pet), hunger: Pet.calculate_next_hunger(pet)}

    pet =
      if Pet.die?(pet) do
        Logger.info("Pet #{pet.id} has died")
        %{pet | is_alive: false}
      else
        pet
      end

    Registry.dispatch(Registry.PetViewers, "pet-#{pet.id}", fn entries ->
      for {pid, _} <- entries, do: send(pid, {:tick, pet})
    end)

    tick_result(pet)
  end

  def handle_call(:get, _, {pet}) do
    {:reply, pet, {pet}}
  end

  def handle_call(:feed, _, {pet}) do
    {:ok, pet} = Pets.update_pet(pet, Map.from_struct(Pet.feed(pet)))
    {:reply, pet, {pet}}
  end

  def handle_cast({:ping}, {pet}) do
    {:noreply, {pet}}
  end

  def terminate(reason, {pet}) do
    Logger.info("Process for pet #{pet.id} is terminating with reason #{inspect(reason)}")

    {Pets.get_pet!(pet.id), pet}
    |> get_pet_changeset()
    |> LivePet.Repo.update()
  end

  defp get_pet_changeset({stale_pet, current_pet}) do
    Pets.change_pet(stale_pet, %{
      age: current_pet.age,
      hunger: current_pet.hunger,
      is_alive: current_pet.is_alive
    })
  end

  defp schedule_tick do
    Process.send_after(self(), :tick, @tick_length_in_milliseconds)
  end

  defp tick_result(%{is_alive: false} = pet) do
    {:stop, :normal, {pet}}
  end

  defp tick_result(pet) do
    {:noreply, {pet}}
  end
end
