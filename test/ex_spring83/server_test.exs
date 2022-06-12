defmodule ExSpring83.ServerTest do
  use ExUnit.Case, async: true
  use Plug.Test
  doctest ExSpring83.Server

  alias ExSpring83.Server

  @opts Server.init([])

  test "returns difficulty_factor" do
    conn =
      conn(:get, "/")
      |> Server.call([])
      |> IO.inspect()

    assert conn.status == 200
    assert String.contains?(conn.resp_body, "difficulty_factor")

    [difficulty_header] = Plug.Conn.get_resp_header(conn, "spring-difficulty")
    assert String.contains?(difficulty_header, "a number")
  end

  test "returns spring version header" do
    conn =
      conn(:get, "/")
      |> Server.call([])

    [version_header] = Plug.Conn.get_resp_header(conn, "spring-version")
    assert String.contains?(version_header, "83")
  end

  # GET /:key
  # spring version header
  # spring auth header
  # board body
  # test key

  # PUT /:key
  # size
  # timestamp
  # signature
  # difficulty_factor
  # test key
end
