defmodule ExSpring83.Boards do
  @moduledoc """
  store and retrieve boards
  """

  alias ExSpring83.Key

  # TODO: struct
  @type t :: String.t()

  @spec get(Key.t()) :: Board.t()
  def get(%Key{string: public_key}) do
    Cachex.get(:boards, public_key)
  end

  @spec put(Key.t(), Board.t(), Ed25519.signature()) :: {:ok, any()} | {:error, any()}
  def put(%Key{} = public_key, board, signature) do
    if Ed25519.valid_signature?(signature |> Base.decode16!(), board, public_key.binary) do
      Cachex.put(:boards, public_key.string, %{board: board, signature: signature})
    else
      {:error, :invalid_signature}
    end
  end
end
