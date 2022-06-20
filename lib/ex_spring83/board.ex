defmodule ExSpring83.Board do
  @moduledoc """
  store and retrieve boards
  """

  alias ExSpring83.Key

  alias __MODULE__

  @enforce_keys [:body, :signature]
  defstruct body: nil, signature: nil

  @type t :: %__MODULE__{body: String.t(), signature: Ed25519.signature()}

  # TODO: wrap the cachex responses, e.g. {:ok, nil} -> {:not_found, _}

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

  @spec boards_stored() :: integer()
  def boards_stored do
    {:ok, count} = Cachex.count(:boards)
    count
  end

  @spec sign(binary(), Ed25519.key(), Ed25519.key()) :: t()
  def sign(message, secret_key, public_key) do
    {:ok,
     %Board{
       body: message,
       signature:
         Ed25519.signature(message, secret_key.binary, public_key.binary) |> Base.encode16()
     }}
  end
end
