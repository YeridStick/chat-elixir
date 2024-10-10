defmodule ElixirChat.Repo.Migrations.CreateMensajes do
  use Ecto.Migration

  def change do
    create table(:mensajes) do
      add :body, :text, null: false
      add :fecha, :utc_datetime, null: false

      timestamps()
    end
  end
end
