defmodule ExSpring83.Server do
  @moduledoc """
  https://github.com/robinsloan/spring-83-spec/blob/main/draft-20220609.md#boards-on-the-server
  """

  # TODO: disable logging in tests
  require Logger

  use Plug.Router

  alias ExSpring83.Board
  alias ExSpring83.Key

  # TODO: break Boards/Board into two modules service/struct
  @board_service ExSpring83.Board

  plug(Plug.Logger)
  plug(:match)
  plug(ExSpring83.Server.Headers)
  plug(:dispatch)

  # TODO: OPTIONS

  get "/" do
    send_resp(conn, 200, "difficulty_factor: #{difficulty_factor()}")
  end

  get "/:key" do
    # TODO: convert to with
    case Key.normalize(key) do
      {:ok, %Key{} = key} ->
        if key == Key.test_key() do
          Logger.info("serving test key")

          send_resp(
            conn,
            200,
            "you asked for the test key! the current timestamp is: #{http_format_datetime()}"
          )
        else
          if Key.valid_public_key?(key) do
            case @board_service.get(key) do
              {:ok, nil} ->
                conn
                |> send_resp(404, "key #{key.string} not found")

              {:ok, %Board{body: body, signature: signature}} ->
                conn
                |> put_resp_header("authorization", "Spring-83 #{signature}")
                |> send_resp(200, "#{body}")
            end
          else
            conn
            |> send_resp(404, "invalid key #{key.string}")
          end
        end

      # key couldn't be normalized
      _ ->
        conn
        |> send_resp(404, "invalid key #{key.string}")
    end
  end

  put "/:key" do
    case Key.normalize(key) do
      {:ok, %Key{} = key} ->
        if key == Key.test_key() do
          send_resp(conn, 401, "you tried to publish the test key!")
        else
          if Key.valid_public_key?(key) do
            # TODO: case do we have this board already?
            case Plug.Conn.get_req_header(conn, "if-unmodified-since") do
              [date_string] ->
                # TODO: compare this to the modified date on our copy of this board
                case Timex.parse(date_string, "%a, %d %b %Y %H:%M:%S %Z", :strftime) do
                  {:ok, dt} ->
                    Logger.debug("if unmodified since: #{dt}")
                    :TODO

                  _ ->
                    :TODO
                end

              _ ->
                :TODO
            end

            case Plug.Conn.read_body(conn, length: 2217) do
              {:ok, body, conn} ->
                [last_modified] =
                  body
                  |> Floki.parse_fragment!()
                  |> Floki.find("meta")
                  |> Floki.attribute("content")

                Logger.debug("last modified: #{last_modified}")

                # check signature
                case Plug.Conn.get_req_header(conn, "authorization") do
                  ["Spring-83 Signature=" <> signature] ->
                    Logger.debug("sig: #{inspect(signature)}")

                    if Ed25519.valid_signature?(Base.decode16!(signature), body, key.binary) do
                      %Board{body: body, signature: signature} |> @board_service.put(key)
                    else
                      :TODO
                    end

                  _ ->
                    :TODO
                end

                # The server must reject the PUT request, returning 400 Bad Request, if

                # the board is transmitted without a last-modified meta tag; or
                # it is transmitted with more than one last-modified meta tag; or
                # its last-modified meta tag isn't parsable as an HTTP-format date and time; or
                # its last-modified meta tag is set to a date in the future.

                # MAX_SIG = (2**256 - 1)
                # key_threshold = MAX_KEY * ( 1.0 - difficulty_factor ) = <an inscrutable gigantic number>
                # The server must reject PUT requests for new keys that are not less than <an inscrutable gigantic number>.
                conn
                |> send_resp(202, "you gave me key: #{key.string} and body #{body}")

              {:more, _partial_body, conn} ->
                conn |> send_resp(413, "board too large")
            end
          else
            conn
            |> send_resp(400, "invalid key #{key.string}")
          end
        end

      # key couldn't be normalized
      _ ->
        conn
        |> send_resp(404, "invalid key #{key.string}")
    end
  end

  match _ do
    conn
    |> send_resp(404, "Not found")
  end

  def boards_stored(board_service \\ @board_service) do
    board_service.boards_stored()
  end

  def difficulty_factor(number_of_boards_stored \\ boards_stored()) do
    (number_of_boards_stored / 10_000_000)
    |> Float.pow(4)
  end

  def key_threshold(difficulty_factor \\ difficulty_factor()) do
    max_key = Integer.pow(2, 256) - 1
    max_key * (1 - difficulty_factor)
  end

  def http_format_datetime(datetime \\ DateTime.now!("Etc/UTC")) do
    datetime |> Calendar.strftime("%a, %d %b %Y %H:%M:%S %Z")
  end
end
