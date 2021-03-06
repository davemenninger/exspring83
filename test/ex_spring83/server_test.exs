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
      conn(:get, "/ab589f4dde9fce4180fcf42c7b05185b0a02a5d682e353fa39177995083e0583")
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
  # difficulty_factor

  test "doesn't accept a board for the test key" do
    conn =
      conn(
        :put,
        "/ab589f4dde9fce4180fcf42c7b05185b0a02a5d682e353fa39177995083e0583",
        "<p>a board</p>"
      )
      |> Server.call([])

    assert conn.status == 401
  end

  test "accepts a board with a valid signature" do
    message = ~S(<meta http-equiv="last-modified" content="Sun, 12 Jun 2022 02:39:31 GMT">)

    public_key =
      ExSpring83.Key.normalize!(
        "7c1e657c38be4571599554138a154b714231838b633895549bbdd1da283e1223"
      )

    secret_key =
      ExSpring83.Key.normalize!(
        "6ecc90c03a308e5a3c79d1815874ee3770e25cc07cf63fddb160eace8d12efb0"
      )

    signature =
      Ed25519.signature(message, secret_key.binary, public_key.binary) |> Base.encode16()

    conn =
      conn(:put, "/#{public_key.string}", "#{message}")
      |> put_req_header("content-type", "text/html")
      |> put_req_header("spring-version", "83")
      |> put_req_header("if-unmodified-since", "#{Server.http_format_datetime()}")
      |> put_req_header("authorization", "Spring-83 Signature=#{signature}")
      |> Server.call([])

    assert conn.status == 202

    conn =
      conn(:get, "/#{public_key.string}")
      |> Server.call([])

    assert conn.resp_body == message
  end

  test "rejects a board with a bad signature" do
  end
end
