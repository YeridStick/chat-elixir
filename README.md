Guía didáctica para tu proyecto ElixirChat, explicando cada archivo y su función. Esta guía te ayudará a entender cómo funciona cada parte del proyecto.

Guía del Proyecto ElixirChat
============================

1. Estructura del Proyecto
--------------------------
Tu proyecto ElixirChat tiene la siguiente estructura básica:

```
elixir_chat/
├── lib/
│   ├── elixir_chat/
│   │   ├── application.ex
│   │   ├── chat_room.ex
│   │   ├── chat_supervisor.ex
│   │   ├── router.ex
│   │   └── socket_handler.ex
│   └── elixir_chat.ex
├── priv/
│   └── static/
│       └── index.html
└── mix.exs
```

2. Archivos y sus Funciones
---------------------------

### mix.exs
Este archivo es el corazón de tu proyecto Elixir. Define las dependencias y la configuración del proyecto.

- `project/0`: Define metadatos del proyecto como nombre, versión y versión de Elixir.
- `application/0`: Especifica las aplicaciones extras y el módulo de inicio.
- `deps/0`: Lista las dependencias del proyecto (plug_cowboy, jason, websock_adapter).

### lib/elixir_chat/application.ex
Este módulo inicia y supervisa todos los procesos de tu aplicación.

- `start/2`: Función de inicio que arranca los procesos hijos (ChatRoom y el servidor web Cowboy).
- Define la estrategia de supervisión (one_for_one).

### lib/elixir_chat/chat_room.ex
Implementa la lógica del chat usando un GenServer.

- `start_link/1`: Inicia el proceso del chat room.
- `init/1`: Inicializa el estado del chat (lista de clientes vacía).
- `join/1`, `leave/1`, `broadcast/1`: Funciones para unirse, salir y enviar mensajes.
- `handle_call/3`, `handle_cast/2`: Manejan las operaciones del chat.

### lib/elixir_chat/chat_supervisor.ex
Supervisa el proceso ChatRoom (aunque actualmente no se usa directamente en application.ex).

- `start_link/1`: Inicia el supervisor.
- `init/1`: Define los procesos hijos a supervisar (ChatRoom).

### lib/elixir_chat/router.ex
Define las rutas HTTP para tu aplicación web.

- Usa `Plug.Router` para definir rutas.
- `get "/"`: Sirve el archivo HTML principal.
- `get "/websocket"`: Maneja la actualización a conexión WebSocket.

### lib/elixir_chat/socket_handler.ex
Maneja las conexiones WebSocket individuales.

- `init/1`: Se llama cuando se establece una nueva conexión WebSocket.
- `handle_in/2`: Procesa los mensajes entrantes del WebSocket.
- `handle_info/2`: Maneja mensajes internos (como broadcasts).
- `terminate/2`: Se llama cuando se cierra una conexión WebSocket.

### priv/static/index.html
La interfaz de usuario HTML para el chat. Contiene:
- Un área para mostrar mensajes.
- Un campo de entrada para escribir mensajes.
- JavaScript para manejar la conexión WebSocket y la interfaz de usuario.

3. Flujo de la Aplicación
-------------------------
1. Cuando inicias la aplicación, `application.ex` arranca el `ChatRoom` y el servidor web.
2. Cuando un usuario accede a "/", el `Router` sirve `index.html`.
3. El JavaScript en `index.html` establece una conexión WebSocket con "/websocket".
4. `SocketHandler` maneja esta conexión, uniéndose al `ChatRoom`.
5. Cuando un usuario envía un mensaje, va a través de `SocketHandler` al `ChatRoom`.
6. `ChatRoom` distribuye el mensaje a todos los `SocketHandler`s conectados.
7. Cada `SocketHandler` envía el mensaje a su cliente WebSocket respectivo.

4. Cómo Ejecutar el Proyecto
----------------------------
1. Asegúrate de tener Elixir instalado.
2. En la terminal, navega al directorio del proyecto.
3. Ejecuta `mix deps.get` para obtener las dependencias.
4. Inicia el servidor con `iex -S mix`.
5. Abre un navegador y ve a `http://localhost:4000`.

Esta guía proporciona una visión general de cómo funciona tu aplicación de chat en tiempo real. Cada archivo juega un papel crucial en el funcionamiento del sistema, desde manejar conexiones web hasta gestionar la lógica del chat en sí.