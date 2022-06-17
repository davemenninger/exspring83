defmodule ExSpring83.BoardTest do
  use ExUnit.Case
  doctest ExSpring83

  alias ExSpring83.Board
  alias ExSpring83.Key

  describe "store boards" do
    setup [:signed_board, :clear_cache]

    test "get/1", %{board: board, public_key: key} do
      {:ok, _} = Board.put(board, key)
      {:ok, got} = Board.get(key)
      assert got == board
    end

    test "put/2", %{board: board, public_key: key} do
      assert {:ok, _} = Board.put(board, key)
    end

    test "boards_stored/0", %{board: board, public_key: key} do
      assert 0 == Board.boards_stored()
      assert {:ok, _} = Board.put(board, key)
      assert 1 == Board.boards_stored()
      assert {:ok, _} = Board.put(board, key)
      assert 1 == Board.boards_stored()
    end
  end

  defp clear_cache(_context) do
    Cachex.clear(:boards)
    :ok
  end

  defp signed_board(_context) do
    message = ~S(<meta http-equiv="last-modified" content="Sun, 12 Jun 2022 02:39:31 GMT">)

    public_key =
      ExSpring83.Key.normalize!(
        "810c9f534933a9509704f48ca670a0ad6bc09a1869a3e352c9e51eaa86ed2049"
      )

    secret_key =
      ExSpring83.Key.normalize!(
        "e2b1f474867de869c1b947baf14d49bec5826601a464c1c52dac3e6f1717c018"
      )

    signature =
      Ed25519.signature(message, secret_key.binary, public_key.binary) |> Base.encode16()

    [
      board: %Board{body: message, signature: signature},
      public_key: public_key,
      secret_key: secret_key
    ]
  end
end
