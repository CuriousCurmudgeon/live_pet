defmodule LivePet.Pets.Server do
  @moduledoc """
  GenServer implementation of a pet. Updates the pet state on
  every tick and accepts messages to interact with it and get it's current
  state.
  """

  use GenServer

  @tick_length_in_milliseconds 5 * 1000

  ### Client process
  def start_link(_) do
    GenServer.start_link(__MODULE__, nil, name: "pet")
  end

  ### Server process
  def init(_) do
    schedule_tick()
    {:ok, {"test"}}
  end

  def handle_info(:tick, state) do
    IO.puts("tick")
    schedule_tick()
    {:noreply, state}
  end

  defp schedule_tick do
    Process.send_after(self(), :tick, @tick_length_in_milliseconds)
  end
end
