defmodule ExSpring83.Board do
  @moduledoc """
  store and retrieve boards
  """

  alias ExSpring83.Key

  alias __MODULE__

  @enforce_keys [:body, :signature]
  defstruct body: nil, signature: nil

  @type t :: %__MODULE__{body: String.t(), signature: Ed25519.signature()}

  @spec get(Key.t()) :: {:ok, Board.t() | nil}
  def get(%Key{string: public_key}) do
    Cachex.get(:boards, public_key)
  end

  @spec put(Board.t(), Key.t()) :: {:ok, any()} | {:error, any()}
  def put(%Board{} = board, %Key{} = public_key) do
    if Ed25519.valid_signature?(
         board.signature |> Base.decode16!(),
         board.body,
         public_key.binary
       ) do
      Cachex.put(:boards, public_key.string, board)
    else
      {:error, :invalid_signature}
    end
  end
end