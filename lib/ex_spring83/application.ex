defmodule ExSpring83.Application do
  @moduledoc false

  use Application
  require Logger

  import Cachex.Spec

  @impl true
  def start(_type, _args) do
    children = [
      # TODO: get some of these values from config
      {Plug.Cowboy, scheme: :http, plug: ExSpring83.Server, port: 4040},
      # cache ttl for boards is 28 days per Spring '83 spec
      {Cachex, name: :boards, expiration: expiration(default: :timer.hours(24) * 28)}
    ]

    Logger.info("Starting application... http://localhost:4040/ ")

    opts = [strategy: :one_for_one, name: ExSpring83.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
