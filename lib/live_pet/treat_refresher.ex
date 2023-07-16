defmodule LivePet.TreatRefresher do
  @moduledoc """
  GenServer that gives all users more treats every 30 minutes,
  up to the max of 5.
  """

  use GenServer
  require Logger
  alias LivePet.Accounts.User
  alias LivePet.Repo

  @refresh_interval_in_milliseconds 30 * 60 * 1000

  ### Client process
  def start_link(_) do
    GenServer.start_link(__MODULE__, nil)
  end

  ### Server process
  def init(_) do
    send(self(), :refresh_treats)
    Logger.info("Treat refresher started")
    {:ok, %{}}
  end

  def handle_info(:refresh_treats, state) do
    schedule_refresh()

    Logger.info("Topping off every user's treats")
    {total_updated, _} = Repo.update_all(User, set: [available_treats: 5])
    Logger.info("Updated #{total_updated} users")

    {:noreply, state}
  end

  defp schedule_refresh do
    Process.send_after(self(), :refresh_treats, @refresh_interval_in_milliseconds)
  end
end
