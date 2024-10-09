Creación de un Chat en Tiempo Real con Elixir y Angular

1. Configuración del Backend (Elixir)
-------------------------------------

1.1. Actualiza las dependencias en `mix.exs`:



```elixir
defp deps do
  [
    {:plug_cowboy, "~> 2.7"},
    {:jason, "~> 1.4"},
    {:websock_adapter, "~> 0.5.7"},
    {:cors_plug, "~> 3.0"}
  ]
end

```

1.2. Ejecuta `mix deps.get` para instalar las nuevas dependencias.

1.3. Configura el Router (`lib/elixir_chat/router.ex`):



```elixir
defmodule ElixirChat.Router do
  use Plug.Router

  plug CORSPlug, origin: ["http://localhost:4200"]

  plug Plug.Parsers,
    parsers: [:json],
    pass: ["application/json"],
    json_decoder: Jason

  plug :match
  plug :dispatch

  get "/api/messages" do
    messages = ElixirChat.ChatRoom.get_messages()
    send_resp(conn, 200, Jason.encode!(messages))
  end

  post "/api/messages" do
    {:ok, body, conn} = read_body(conn)
    case Jason.decode(body) do
      {:ok, %{"body" => message_body}} ->
        ElixirChat.ChatRoom.broadcast(%{event: "new_msg", body: message_body})
        send_resp(conn, 201, Jason.encode!(%{status: "sent", message: message_body}))
      _ ->
        send_resp(conn, 400, Jason.encode!(%{error: "Invalid message format"}))
    end
  end

  get "/websocket" do
    conn = Plug.Conn.fetch_query_params(conn)
    WebSockAdapter.upgrade(conn, ElixirChat.SocketHandler, [], timeout: 60_000)
  end

  match _ do
    send_resp(conn, 404, Jason.encode!(%{error: "Not found"}))
  end
end

```

1.4. Actualiza el ChatRoom (`lib/elixir_chat/chat_room.ex`):



```elixir
defmodule ElixirChat.ChatRoom do
  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_) do
    {:ok, %{messages: [], clients: MapSet.new()}}
  end

  def get_messages do
    GenServer.call(__MODULE__, :get_messages)
  end

  def broadcast(message) do
    GenServer.cast(__MODULE__, {:broadcast, message})
  end

  def handle_call(:get_messages, _from, state) do
    {:reply, state.messages, state}
  end

  def handle_cast({:broadcast, message}, state) do
    new_message = Map.put(message, :timestamp, :os.system_time(:millisecond))
    new_state = %{state | messages: [new_message | state.messages]}
    Enum.each(state.clients, &send(&1, {:broadcast, new_message}))
    {:noreply, new_state}
  end

  # ... (otros métodos como join y leave)
end

```

2. Configuración del Frontend (Angular)
---------------------------------------

2.1. Crea un servicio para manejar la comunicación con el backend:



```typescript
import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable, BehaviorSubject } from 'rxjs';
import { webSocket, WebSocketSubject } from 'rxjs/webSocket';

@Injectable({
  providedIn: 'root'
})
export class ChatService {
  private apiUrl = 'http://localhost:4000/api';
  private wsUrl = 'ws://localhost:4000/websocket';
  private socket$: WebSocketSubject<any>;
  private messagesSubject = new BehaviorSubject<any[]>([]);

  constructor(private http: HttpClient) {
    this.socket$ = webSocket(this.wsUrl);
    this.socket$.subscribe(
      msg => this.handleNewMessage(msg),
      err => console.error(err),
      () => console.log('WebSocket connection closed')
    );
  }

  getMessages(): Observable<any[]> {
    return this.messagesSubject.asObservable();
  }

  sendMessage(message: string): Observable<any> {
    return this.http.post(`${this.apiUrl}/messages`, { body: message });
  }

  private handleNewMessage(msg: any) {
    const currentMessages = this.messagesSubject.value;
    this.messagesSubject.next([...currentMessages, msg]);
  }

  loadInitialMessages() {
    this.http.get<any[]>(`${this.apiUrl}/messages`).subscribe(
      messages => this.messagesSubject.next(messages),
      error => console.error('Error loading messages', error)
    );
  }
}

```

2.2. Crea un componente para el chat:



```typescript
import { Component, OnInit } from '@angular/core';
import { ChatService } from './chat.service';

@Component({
  selector: 'app-chat',
  template: `
    <div *ngFor="let message of messages">
      {{ message.body }}
    </div>
    <input #messageInput (keyup.enter)="sendMessage(messageInput.value); messageInput.value = ''">
    <button (click)="sendMessage(messageInput.value); messageInput.value = ''">Send</button>
  `
})
export class ChatComponent implements OnInit {
  messages: any[] = [];

  constructor(private chatService: ChatService) {}

  ngOnInit() {
    this.chatService.getMessages().subscribe(messages => {
      this.messages = messages;
    });
    this.chatService.loadInitialMessages();
  }

  sendMessage(message: string) {
    if (message.trim()) {
      this.chatService.sendMessage(message).subscribe(
        response => console.log('Message sent', response),
        error => console.error('Error sending message', error)
      );
    }
  }
}

```

3. Iniciar la Aplicación
------------------------

3.1. Inicia el servidor Elixir:
```
iex -S mix
```

3.2. Inicia la aplicación Angular:
```
ng serve
```

3.3. Abre un navegador y ve a `http://localhost:4200` para usar la aplicación de chat.

Esta guía actualizada incluye:
- Configuración de CORS en el backend Elixir.
- Implementación de endpoints REST para obtener y enviar mensajes.
- Un servicio Angular para manejar la comunicación HTTP y WebSocket con el backend.
- Un componente Angular básico para la interfaz de usuario del chat.

Recuerda que esta es una implementación básica y puede necesitar ajustes adicionales para manejar errores, reconexiones de WebSocket, y otras consideraciones de producción.
