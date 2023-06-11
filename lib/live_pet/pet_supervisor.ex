defmodule LivePet.PetSupervisor do
  use DynamicSupervisor

  require Logger
  alias LivePet.Pets

  def start_link(init_arg) do
    DynamicSupervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  @impl true
  def init(_init_arg) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  def start_pets() do
    Logger.info("Starting all alive pets")

    start_timestamp = DateTime.utc_now()

    number_started =
      Pets.list_live_pets()
      |> tap(&Logger.info("Starting #{length(&1)} pets"))
      |> Enum.map(&start_pet_server/1)
      |> Enum.filter(fn result -> result != nil end)
      |> length()

    duration = DateTime.diff(DateTime.utc_now(), start_timestamp, :millisecond)
    Logger.info("Started #{number_started} pets in #{duration} milliseconds")
  end

  def start_pet_server(pet) do
    %{active: partition_count} = PartitionSupervisor.count_children(__MODULE__)

    case DynamicSupervisor.start_child(
           {:via, PartitionSupervisor, {__MODULE__, :rand.uniform(partition_count)}},
           {Pets.Server, pet}
         ) do
      {:ok, pid} ->
        pid

      {:error, error} ->
        # TODO: improved error handling
        Logger.error(inspect(error))
        nil
    end
  end
end
