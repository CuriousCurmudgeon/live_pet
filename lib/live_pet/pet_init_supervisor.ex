defmodule LivePet.PetInitSupervisor do
  @moduledoc """
  Wrapper around PetSupervisor to start all pets as well. DynamicSupervisor does
  not support a list of children to start with, so this is how we work around it.
  See https://github.com/slashdotdash/til/blob/master/elixir/dynamic-supervisor-start-children.md
  """
  use Supervisor

  alias LivePet.PetSupervisor

  def start_link(init_arg) do
    Supervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  @impl true
  def init(_init_arg) do
    children = [
      PetSupervisor,
      {Task, &PetSupervisor.start_pets/0}
    ]

    opts = [strategy: :rest_for_one]

    Supervisor.init(children, opts)
  end
end
