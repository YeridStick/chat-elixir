defmodule ElixirChat.SocketHandler do
  @behaviour WebSock

  def init(state) do
    ElixirChat.ChatRoom.join(self())
    {:ok, state}
  end

  def handle_in({text, _opts}, state) do
    case Jason.decode(text) do
      {:ok, %{"event" => "new_msg", "body" => body}} ->
        ElixirChat.ChatRoom.broadcast(%{event: "new_msg", body: body})
        {:ok, state}
      _ ->
        {:ok, state}
    end
  end

  def handle_info({:new_message, message}, state) do
    {:push, {:text, Jason.encode!(message)}, state}
  end

  def terminate(_reason, _state) do
    ElixirChat.ChatRoom.leave(self())
    :ok
  end
end
