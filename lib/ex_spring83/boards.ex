defmodule ExSpring83.Boards do
  @moduledoc """
  store and retrieve boards
  """

  def get(public_key) do
    Cachex.get(:boards, public_key)
  end
end
