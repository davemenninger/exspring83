defmodule ExSpring83.Server do
  @moduledoc """
  https://github.com/robinsloan/spring-83-spec/blob/main/draft-20220609.md#boards-on-the-server
  """

  use Plug.Router

  alias ExSpring83.Key
  alias ExSpring83.Boards

  plug(Plug.Logger)
  plug(:match)
  plug :spring83_version_header
  plug(:dispatch)

  get "/" do
    conn
    |> put_resp_content_type("text/html")
    |> put_resp_header("spring-difficulty", "#{difficulty_factor()}")
    |> send_resp(200, "difficulty_factor: #{difficulty_factor()}")
  end

  get "/fad415fbaa0339c4fd372d8287e50f67905321ccfd9c43fa4c20ac40afed1983" do
    conn
    |> put_resp_content_type("text/plain")
    |> send_resp(200, "you asked for the test key!")
  end

  get "/:key" do
    if Key.valid_public_key?(key) do
      case Boards.get(key) do
        {:ok, nil} ->
          conn
          |> send_resp(404, "key #{key} not found")

        {:ok, board} ->
          signature = :TODO

          conn
          |> put_resp_content_type("text/html")
          |> put_resp_header("authorization", "Spring-83 #{signature}")
          |> send_resp(200, "you asked for key: #{key} - board: #{board}")
      end
    else
      conn
      |> send_resp(404, "key #{key} not found")
    end
  end

  # https://github.com/robinsloan/spring-83-spec/blob/main/draft-20220609.md#verifying-boards
  put "/fad415fbaa0339c4fd372d8287e50f67905321ccfd9c43fa4c20ac40afed1983" do
    send_resp(conn, 401, "you tried to publish the test key!")
  end

  put "/:key" do
    # check if unmodified
    case Plug.Conn.get_req_header(conn, "if-unmodified-since") do
      [date_string] ->
        # TODO: compare this to the modified date on our copy of this board
        date_string

      _ ->
        :TODO
    end

    case Plug.Conn.read_body(conn, length: 2217) do
      {:ok, body, conn} ->
        # check signature
        case Plug.Conn.get_req_header(conn, "authorization") do
          ["Spring-83 Signature=" <> signature] ->
            Ed25519.valid_signature?(signature |> Base.decode16!(), body, key |> Base.decode16!())

          _ ->
            :TODO
        end

        # The server must reject the PUT request, returning 400 Bad Request, if

        # the board is transmitted without a last-modified meta tag; or
        # it is transmitted with more than one last-modified meta tag; or
        # its last-modified meta tag isn't parsable as an HTTP-format date and time; or
        # its last-modified meta tag is set to a date in the future.

        # # HTTP date format:
        # Calendar.strftime(DateTime.now!("Etc/UTC"), "%a, %d %b %Y %H:%M:%S GMT")

        # MAX_SIG = (2**256 - 1)
        # key_threshold = MAX_KEY * ( 1.0 - difficulty_factor ) = <an inscrutable gigantic number>
        # The server must reject PUT requests for new keys that are not less than <an inscrutable gigantic number>.
        conn
        |> send_resp(202, "you gave me key: #{key} and body #{body}")

      {:more, _partial_body, conn} ->
        conn |> send_resp(413, "board too large")
    end
  end

  match _ do
    conn
    |> send_resp(404, "Not found")
  end

  def difficulty_factor(number_of_boards_stored \\ 1) do
    (number_of_boards_stored / 10_000_000)
    |> Float.pow(4)
  end

  def spring83_version_header(conn, _opts) do
    put_resp_header(conn, "spring-version", "83")
  end
end
