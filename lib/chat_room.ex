defmodule ElixirChat.ChatRoom do
  use GenServer
  alias ElixirChat.{Repo, Mensaje}
  import Ecto.Query

  def start_link(_) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_) do
    {:ok, %{clients: MapSet.new()}}
  end

  def get_messages do
    Mensaje
    |> order_by([m], desc: m.inserted_at)
    |> limit(100)
    |> Repo.all()
    |> Enum.map(fn m -> %{body: m.body, fecha: m.fecha} end)
  end

  def delete_all_messages do
    Repo.delete_all(Mensaje)
    broadcast(%{event: "messages_deleted"})
    :ok
  end

  def broadcast(message) do
    GenServer.cast(__MODULE__, {:broadcast, message})
  end

  # Métodos para unirse y dejar el chat
  def join(pid), do: GenServer.cast(__MODULE__, {:join, pid})
  def leave(pid), do: GenServer.cast(__MODULE__, {:leave, pid})

  # Agrupamos todas las cláusulas de handle_cast/2 juntas
  def handle_cast({:broadcast, %{event: "new_msg", body: body}}, state) do
    attrs = %{body: body, fecha: DateTime.utc_now()}
    {:ok, mensaje} = %Mensaje{} |> Mensaje.changeset(attrs) |> Repo.insert()

    message_data = %{body: mensaje.body, fecha: mensaje.fecha}
    Enum.each(state.clients, &send(&1, {:new_message, message_data}))
    {:noreply, state}
  end

  def handle_cast({:join, pid}, state) do
    {:noreply, %{state | clients: MapSet.put(state.clients, pid)}}
  end

  def handle_cast({:leave, pid}, state) do
    {:noreply, %{state | clients: MapSet.delete(state.clients, pid)}}
  end
end
