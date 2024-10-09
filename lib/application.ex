defmodule ElixirChat.Application do
  use Application

  def start(_type, _args) do
    children = [
      ElixirChat.ChatRoom,
      {Plug.Cowboy, scheme: :http, plug: ElixirChat.Router, options: [port: 4000]}
    ]

    opts = [strategy: :one_for_one, name: ElixirChat.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
