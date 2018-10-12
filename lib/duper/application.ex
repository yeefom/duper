defmodule Duper.Application do
  use Application

  def start(_type, _args) do
    children = [
      Duper.Results,
      { DUper.PathFinder, "." },
      Duper.WorkerSupervisor
    ]

    opts = [strategy: :one_for_all, name: Duper.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
