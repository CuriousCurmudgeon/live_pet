defmodule LivePet.Pets.Simulation do
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

  Returns an error tuple if the pet is not found or is dead

  ## Examples

      iex> get_pet(123)
      {:ok, %Pet{}}

      iex> get_pet(456)
      {:error, :dead, %Pet{}}

      iex> get_pet(789)
      {:error, :not_found}
  """
  def get_pet(pet_id) do
    process_name = get_process_name(pet_id)

    case GenServer.whereis(process_name) do
      nil ->
        get_pet_error(pet_id)

      pid ->
        {:ok, GenServer.call(pid, :get_pet)}
    end
  end

  @doc """
  Feed the pet. Updates all viewers with new pet state.

  ## Examples

      iex> feed(123)
      :ok
  """
  def feed(pet_id, type) when type in [:normal, :treat] do
    GenServer.cast(get_process_name(pet_id), {:feed, type})
  end

  defp get_process_name(pet_id) do
    {:via, :global, "pet-#{pet_id}"}
  end

  defp get_pet_error(pet_id) do
    case Pets.get_pet(pet_id) do
      %Pet{is_alive: false} = pet -> {:error, :dead, pet}
      nil -> {:error, :not_found}
    end
  end

  ### Server process
  def init(pet) do
    Logger.debug("Starting pet #{pet.id}")
    schedule_tick()
    {:ok, pet}
  end

  def handle_info(:tick, pet) do
    schedule_tick()

    pet =
      simulate_tick(pet)
      |> update_viewers()

    case pet do
      %{is_alive: false} ->
        Logger.info("Pet #{pet.id} has died")
        {:stop, :normal, pet}

      _ ->
        {:noreply, pet}
    end
  end

  def handle_call(:get_pet, _, pet) do
    {:reply, pet, pet}
  end

  def handle_cast({:feed, type}, pet) do
    {:noreply,
     Pets.change_pet(pet)
     |> Pet.feed(type)
     |> Ecto.Changeset.apply_changes()
     |> update_viewers()}
  end

  def terminate(reason, pet) do
    Logger.info("Process for pet is terminating with reason #{inspect(reason)}")

    {:ok, pet} =
      Pets.get_pet(pet.id)
      |> Pets.update_pet(Map.from_struct(pet))

    Logger.info("Persisted dead pet #{pet.id}")
  end

  defp schedule_tick do
    Process.send_after(self(), :tick, @tick_length_in_milliseconds)
  end

  defp simulate_tick(pet) do
    Pets.change_pet(pet)
    |> Pet.increment_age()
    |> Pet.increment_hunger()
    |> maybe_die()
    |> Ecto.Changeset.apply_changes()
  end

  defp maybe_die(changeset) do
    if Pet.die?(changeset) do
      Ecto.Changeset.put_change(changeset, :is_alive, false)
    else
      changeset
    end
  end

  defp update_viewers(pet) do
    Registry.dispatch(Registry.PetViewers, "pet-#{pet.id}", fn entries ->
      for {pid, _} <- entries, do: send(pid, {:update, pet})
    end)

    pet
  end
end
