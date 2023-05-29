defmodule LivePet.Pets.Server do
  @moduledoc """
  GenServer implementation of a pet. Updates the pet state on
  every tick and accepts messages to interact with it and get it's current
  state.
  """

  use GenServer

  ### Client process
  def start_link(_) do
    GenServer.start_link(__MODULE__, nil, name: "pet")
  end

  ### Server process
  def init(_) do
    {:ok, {"test"}}
  end
end
