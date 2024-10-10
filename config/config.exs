import Config

config :elixir_chat, ecto_repos: [ElixirChat.Repo]

config :elixir_chat, ElixirChat.Repo,
  database: "chatsDb",
  username: "user",
  password: "password",
  hostname: "localhost",
  port: 5432
