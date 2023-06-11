defmodule LivePet.PetSupervisor do
  use DynamicSupervisor, restart: :transient

  alias LivePet.Pets

  def start_link(init_arg) do
    DynamicSupervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  @impl true
  def init(_init_arg) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  def start_pets() do
    Pets.list_live_pets()
    |> tap(fn pets -> IO.puts("Starting #{length(pets)} pets") end)
    |> Enum.map(&start_pet_server/1)
  end

  def start_pet_server(pet) do
    case DynamicSupervisor.start_child(LivePet.PetSupervisor, {Pets.Server, pet}) do
      {:ok, _} ->
        nil

      {:error, error} ->
        # TODO: improved error handling
        IO.inspect(error)
    end
  end
end
