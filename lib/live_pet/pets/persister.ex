defmodule LivePet.Pets.Persister do
  @moduledoc """
  GenServer that persists all pets on a periodic basis.
  Pulls all pets from Registry.Pets
  """

  use GenServer
  require Logger
  alias Ecto.Multi
  alias LivePet.Pets
  alias LivePet.Repo

  @persist_interval_in_milliseconds 60 * 1000
  @load_limit 1000

  ### Client process
  def start_link(_) do
    GenServer.start_link(__MODULE__, nil)
  end

  ### Server process
  def init(_) do
    schedule_persist()
    {:ok, new_state()}
  end

  def handle_info(:persist_stale, {timestamp}) do
    schedule_persist()
    Logger.info("Starting pet persistence")
    total_updated = persist_pets(timestamp)

    Logger.info("Updated #{total_updated} pets")

    {:noreply, new_state()}
  end

  defp new_state() do
    {DateTime.utc_now()}
  end

  defp schedule_persist do
    Process.send_after(self(), :persist_stale, @persist_interval_in_milliseconds)
  end

  defp persist_pets(timestamp, total_updated \\ 0) do
    Pets.list_stale_pets(timestamp, @load_limit)
    |> maybe_persist(timestamp, total_updated)
  end

  defp maybe_persist([], _, total_updated), do: total_updated

  defp maybe_persist(stale_pets, timestamp, total_updated) do
    {:ok, updated_pets} =
      stale_pets
      |> Enum.map(&get_pet_changeset/1)
      |> Enum.reduce(Multi.new(), fn changeset, multi ->
        Multi.update(multi, "pet-#{changeset.data.id}", changeset)
      end)
      |> Repo.transaction()

    persist_pets(timestamp, total_updated + (Map.keys(updated_pets) |> length()))
  end

  defp get_pet_changeset(pet) do
    {:ok, simulated_pet} = Pets.Simulation.get_pet(pet.id)

    Pets.get_pet(pet.id)
    |> Pets.change_pet(Map.from_struct(simulated_pet))
  end
end
