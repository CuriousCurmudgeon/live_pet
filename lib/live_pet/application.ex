defmodule LivePet.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      LivePetWeb.Telemetry,
      # Start the Ecto repository
      LivePet.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: LivePet.PubSub},
      # Start Finch
      {Finch, name: LivePet.Finch},
      # Start the Endpoint (http/https)
      LivePetWeb.Endpoint
      # Start a worker by calling: LivePet.Worker.start_link(arg)
      # {LivePet.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: LivePet.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    LivePetWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
