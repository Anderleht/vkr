defmodule Vkr.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  alias Vkr.AutoMigrationWorker
  alias Vkr.RequestCaptureWorker

  @impl true
  def start(_type, _args) do
    children = [
      VkrWeb.Telemetry,
      Vkr.Repo,
      AutoMigrationWorker,
      {Phoenix.PubSub, name: Vkr.PubSub},
      RequestCaptureWorker,
      VkrWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Vkr.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    VkrWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
