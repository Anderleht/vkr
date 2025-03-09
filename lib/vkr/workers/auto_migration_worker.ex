defmodule Vkr.AutoMigrationWorker do
  @moduledoc false
  use GenServer, restart: :transient

  def start_link(_) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_args) do
    Vkr.Repo
    |> Ecto.Migrator.migrations()
    |> Enum.any?(&match?({:down, _, _}, &1))
    |> case do
      true -> Vkr.Release.migrate(false)
      false -> :ok
    end

    :ignore
  end
end
