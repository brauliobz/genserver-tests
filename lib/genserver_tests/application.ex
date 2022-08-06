defmodule GenserverTests.Application do
  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # GenserverTests.SimpleGenserver,
      GenserverTests.ServerWithoutGenserver
    ]

    Supervisor.start_link(children, strategy: :one_for_one)
  end
end
