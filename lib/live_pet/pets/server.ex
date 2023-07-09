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
    GenServer.start_link(__MODULE__, pet, name: get_process_name(pet.id))
  end

  @doc """
  Get the current state of the pet
  """
  def pet(pet_id) do
    GenServer.call(get_process_name(pet_id), :changeset)
    |> Ecto.Changeset.apply_changes()
  end

  @doc """
  Get the current changeset for the pet
  """
  def changeset(pet_id) do
    GenServer.call(get_process_name(pet_id), :changeset)
  end

  def ping(pet_id) do
    GenServer.cast(get_process_name(pet_id), {:ping})
  end

  def feed(pet_id) do
    GenServer.call(get_process_name(pet_id), :feed)
  end

  defp get_process_name(pet_id) do
    {:via, :global, "pet-#{pet_id}"}
  end

  ### Server process
  def init(pet) do
    Logger.info("Starting pet #{pet.id}")
    schedule_tick()
    {:ok, {Pets.change_pet(pet)}}
  end

  def handle_info(:tick, {changeset}) do
    schedule_tick()

    pet = Ecto.Changeset.apply_changes(changeset)

    changeset =
      changeset
      |> Pet.increment_age()
      |> Pet.increment_hunger()

    changeset =
      if Pet.die?(changeset) do
        Ecto.Changeset.put_change(changeset, :is_alive, false)
      else
        changeset
      end

    pet = Ecto.Changeset.apply_changes(changeset)

    Registry.dispatch(Registry.PetViewers, "pet-#{pet.id}", fn entries ->
      for {pid, _} <- entries, do: send(pid, {:tick, pet})
    end)

    case pet do
      %{is_alive: false} ->
        Logger.info("Pet #{pet.id} has died")
        {:stop, :normal, {changeset}}

      _ ->
        {:noreply, {changeset}}
    end
  end

  def handle_call(:changeset, _, {changeset}) do
    {:reply, changeset, {changeset}}
  end

  def handle_call(:feed, _, {changeset}) do
    changeset = Pet.feed(changeset)
    {:reply, Ecto.Changeset.apply_changes(changeset), {changeset}}
  end

  def handle_cast({:ping}, {changeset}) do
    {:noreply, {changeset}}
  end

  def terminate(reason, {changeset}) do
    Logger.info("Process for pet is terminating with reason #{inspect(reason)}")

    {:ok, pet} = LivePet.Repo.update(changeset)
    Logger.info("Persisted dead pet #{pet.id}")
  end

  defp schedule_tick do
    Process.send_after(self(), :tick, @tick_length_in_milliseconds)
  end
end
