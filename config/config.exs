import Config

config :elixir_chat, ecto_repos: [ElixirChat.Repo]

config :elixir_chat, ElixirChat.Repo,
  database: "elixir-ejemplo",
  username: "elixir",
  password: "elixir",
  hostname: "localhost"
