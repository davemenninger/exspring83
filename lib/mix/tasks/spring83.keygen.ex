defmodule Mix.Tasks.Spring83.KeyGen do
  @moduledoc """
  Task to hunt for valid Spring83 keys

  Generates keys randomly until finding a valid one
  """

  use Mix.Task

  alias ExSpring83.Key

  # milliseconds between tries
  @sleep 10

  @type keypair() :: {Ed25519.key(), Ed25519.key()}

  def run(args) do
    {secret_key, public_key} = Ed25519.generate_key_pair()

    Key.puts_keypair({secret_key, public_key})

    # TODO: support looking for the current year + 1
    key = public_key |> Base.encode16() |> Key.normalize()

    if Key.valid_public_key?(key) do
      IO.puts("found one!")
      Key.puts_keypair({secret_key, public_key})
    else
      # TODO don't sleep, use message passing
      Process.sleep(@sleep)
      run(args)
    end
  end
end
