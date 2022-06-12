defmodule ExSpring83.ServerTest do
  use ExUnit.Case, async: true
  use Plug.Test
  doctest ExSpring83.Server

  alias ExSpring83.Server

  @opts Server.init([])

  test "returns difficulty_factor" do
    conn = conn(:get, "/") |> Server.call([])

    assert conn.status == 200
    assert String.contains?(conn.resp_body, "difficulty_factor")

    [difficulty_header] = Plug.Conn.get_resp_header(conn, "spring-difficulty")
    difficulty_factor = String.to_float(difficulty_header)

    assert is_number(difficulty_factor)

    [content_type_header] = Plug.Conn.get_resp_header(conn, "content-type")

    assert "text/html; charset=utf-8" == content_type_header
  end

  test "returns spring version header" do
    conn = conn(:get, "/") |> Server.call([])
    [version_header] = Plug.Conn.get_resp_header(conn, "spring-version")

    assert String.contains?(version_header, "83")
  end

  test "responds for the test key" do
    conn =
      conn(:get, "/fad415fbaa0339c4fd372d8287e50f67905321ccfd9c43fa4c20ac40afed1983")
      |> Server.call([])

    assert conn.status == 200

    [version_header] = Plug.Conn.get_resp_header(conn, "spring-version")
    assert String.contains?(version_header, "83")
  end

  # GET /:key
  # spring version header
  # spring auth header
  # board body

  # PUT /:key
  # size
  # timestamp
  # signature
  # difficulty_factor
  # test key

  test "doesn't accept a board for the test key" do
    conn =
      conn(
        :put,
        "/fad415fbaa0339c4fd372d8287e50f67905321ccfd9c43fa4c20ac40afed1983",
        "<p>a board</p>"
      )
      |> Server.call([])

    assert conn.status == 401
  end
end
