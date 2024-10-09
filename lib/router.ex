defmodule ElixirChat.Router do
  use Plug.Router

  plug Plug.Static,
    at: "/",
    from: {:elixir_chat, "priv/static"}
  plug :match
  plug :dispatch

  get "/" do
    conn
    |> put_resp_content_type("text/html")
    |> send_file(200, "priv/static/index.html")
  end

  get "/websocket" do
    conn = Plug.Conn.fetch_query_params(conn)
    WebSockAdapter.upgrade(conn, ElixirChat.SocketHandler, [], timeout: 60_000)
  end

  match _ do
    send_resp(conn, 404, "Not found")
  end
end
