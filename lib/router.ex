defmodule ElixirChat.Router do
  use Plug.Router

  plug CORSPlug, origin: "*"

  plug Plug.Parsers,
    parsers: [:json],
    pass: ["application/json"],
    json_decoder: Jason

  plug :match
  plug :dispatch

  # Endpoint para obtener todos los mensajes
  get "/api/messages" do
    messages = ElixirChat.ChatRoom.get_messages()
    send_resp(conn, 200, Jason.encode!(messages))
  end

  delete "/api/messages" do
    ElixirChat.ChatRoom.delete_all_messages()
    send_resp(conn, 200, Jason.encode!(%{status: "success", message: "All messages deleted"}))
  end

  post "/api/messages" do
    IO.puts("Received params: #{inspect(conn.params)}")  # Línea de depuración
    case conn.params do
      %{"body" => message_body} ->
        ElixirChat.ChatRoom.broadcast(%{event: "new_msg", body: message_body})
        send_resp(conn, 201, Jason.encode!(%{status: "sent", message: message_body}))
      _ ->
        IO.puts("Invalid format received: #{inspect(conn.params)}")  # Línea de depuración
        send_resp(conn, 400, Jason.encode!(%{error: "Invalid message format"}))
    end
  end

  # Endpoint WebSocket para conexiones en tiempo real
  get "/websocket" do
    conn = Plug.Conn.fetch_query_params(conn)
    WebSockAdapter.upgrade(conn, ElixirChat.SocketHandler, [], timeout: 60_000)
  end

  match _ do
    send_resp(conn, 404, Jason.encode!(%{error: "Not found"}))
  end
end
