defmodule GroceryScheduler.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      GrocerySchedulerWeb.Telemetry,
      GroceryScheduler.Repo,
      {DNSCluster, query: Application.get_env(:grocery_scheduler, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: GroceryScheduler.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: GroceryScheduler.Finch},
      # Start a worker by calling: GroceryScheduler.Worker.start_link(arg)
      # {GroceryScheduler.Worker, arg},
      # Start to serve requests, typically the last entry
      GrocerySchedulerWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: GroceryScheduler.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    GrocerySchedulerWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
