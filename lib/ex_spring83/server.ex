defmodule ExSpring83.Server do
  @moduledoc """
  https://github.com/robinsloan/spring-83-spec/blob/main/draft-20220609.md#boards-on-the-server
  """

  use Plug.Router

  alias ExSpring83.Key

  plug(Plug.Logger)
  plug(:match)
  plug(:dispatch)

  get "/" do
    conn
    |> put_resp_content_type("text/plain")
    |> put_resp_header("spring-version", "83")
    |> put_resp_header("spring-difficulty", "#{difficulty_factor()}")
    |> send_resp(200, "difficulty_factor: #{difficulty_factor()}")
  end

  get "/fad415fbaa0339c4fd372d8287e50f67905321ccfd9c43fa4c20ac40afed1983" do
    send_resp(conn, 200, "you asked for the test key!")
  end

  get "/:key" do
    if Key.valid_public_key?(key) do
      send_resp(conn, 200, "you asked for key: #{key}")
    else
      send_resp(conn, 404, "you asked for key: #{key}")
    end
  end

  put "/:key" do
    # {:ok, body, conn} = Plug.Conn.read_body(conn, length: 2217)
    # MAX_SIG = (2**256 - 1)
    # key_threshold = MAX_SIG * ( 1.0 - difficulty_factor)
    send_resp(conn, 202, "you gave me key: #{key}")
  end

  def difficulty_factor(number_of_boards_stored \\ 1) do
    (number_of_boards_stored / 10_000_000)
    |> Float.pow(4)
  end
end
