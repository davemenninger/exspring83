defmodule ExSpring83.Server.Headers do
  import Plug.Conn

  alias ExSpring83.Server

  def init(opts) do
    opts
  end

  def call(conn, opts) do
    conn
    |> spring83_content_type_header(opts)
    |> spring83_version_header(opts)
    |> spring83_difficulty_header(opts)
  end

  def spring83_content_type_header(conn, _opts) do
    put_resp_content_type(conn, "text/html")
  end

  def spring83_version_header(conn, _opts) do
    put_resp_header(conn, "spring-version", "83")
  end

  def spring83_difficulty_header(conn, _opts) do
    put_resp_header(conn, "spring-difficulty", "#{Server.difficulty_factor()}")
  end
end
