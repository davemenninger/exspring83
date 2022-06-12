defmodule ExSpring83.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {Plug.Cowboy, scheme: :http, plug: ExSpring83.Server, port: 4040}
    ]

    opts = [strategy: :one_for_one, name: ExSpring83.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
