defmodule LivePet.Pets.Persister do
  @moduledoc """
  GenServer that persists all pets on a periodic basis.
  Pulls all pets from Registry.Pets
  """

  use GenServer
  import Ecto.Changeset
  alias LivePet.Pets

  @persist_interval_in_milliseconds 60 * 1000

  ### Client process
  def start_link(_) do
    GenServer.start_link(__MODULE__, nil)
  end

  ### Server process
  def init(_) do
    schedule_persist()
    {:ok, new_state()}
  end

  def handle_info(:persist, state) do
    # TODO:
    # - Track the last persist timestamp in the state
    # - Load pets in chunks of 1000 with an updated timestamp before that
    # - Get the state of each of those pets from their process
    # - Create a changeset for each using Ecto.Multi
    # - Persist
    IO.puts("Persisting!")
    schedule_persist()
    {:noreply, new_state()}
  end

  defp new_state() do
    {DateTime.utc_now()}
  end

  defp schedule_persist do
    Process.send_after(self(), :persist, @persist_interval_in_milliseconds)
  end
end
