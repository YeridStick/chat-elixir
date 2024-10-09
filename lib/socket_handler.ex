defmodule ElixirChat.SocketHandler do
  @behaviour WebSock

  @impl WebSock
  def init(_args) do
    ElixirChat.ChatRoom.join(self())
    {:ok, %{}}
  end

  @impl WebSock
  def handle_in({data, [opcode: :text]}, state) do
    case Jason.decode(data) do
      {:ok, %{"event" => "new_msg", "body" => body}} ->
        ElixirChat.ChatRoom.broadcast(%{event: "new_msg", body: body})
        {:ok, state}
      _ ->
        {:ok, state}
    end
  end

  @impl WebSock
  def handle_info({:broadcast, message}, state) do
    {:push, {:text, Jason.encode!(message)}, state}
  end

  @impl WebSock
  def terminate(_reason, state) do
    ElixirChat.ChatRoom.leave(self())
    {:ok, state}
  end
end
