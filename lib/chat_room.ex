defmodule ElixirChat.ChatRoom do
  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def init(_) do
    {:ok, %{clients: MapSet.new(), messages: []}}
  end

  def join(pid) do
    GenServer.call(__MODULE__, {:join, pid})
  end

  def leave(pid) do
    GenServer.cast(__MODULE__, {:leave, pid})
  end

  def broadcast(message) do
    GenServer.cast(__MODULE__, {:broadcast, message})
  end

  def get_messages do
    GenServer.call(__MODULE__, :get_messages)
  end

  def handle_call({:join, pid}, _from, state) do
    new_state = %{state | clients: MapSet.put(state.clients, pid)}
    {:reply, :ok, new_state}
  end

  def handle_call(:get_messages, _from, state) do
    {:reply, Enum.reverse(state.messages), state}
  end

  def handle_cast({:leave, pid}, state) do
    new_state = %{state | clients: MapSet.delete(state.clients, pid)}
    {:noreply, new_state}
  end

  def handle_cast({:broadcast, message}, state) do
    new_message = Map.put(message, :timestamp, :os.system_time(:millisecond))
    new_state = %{state | messages: [new_message | state.messages]}
    Enum.each(state.clients, fn pid ->
      send(pid, {:broadcast, new_message})
    end)
    {:noreply, new_state}
  end
end
