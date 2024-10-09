defmodule ElixirChat.ChatRoom do
  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def init(_) do
    {:ok, %{clients: MapSet.new()}}
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

  def handle_call({:join, pid}, _from, state) do
    new_state = %{state | clients: MapSet.put(state.clients, pid)}
    {:reply, :ok, new_state}
  end

  def handle_cast({:leave, pid}, state) do
    new_state = %{state | clients: MapSet.delete(state.clients, pid)}
    {:noreply, new_state}
  end

  def handle_cast({:broadcast, message}, state) do
    Enum.each(state.clients, fn pid ->
      send(pid, {:broadcast, message})
    end)
    {:noreply, state}
  end
end
