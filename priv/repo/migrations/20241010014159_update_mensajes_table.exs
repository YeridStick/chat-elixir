defmodule ElixirChat.Repo.Migrations.UpdateMensajesTable do
  use Ecto.Migration

  def change do
    alter table(:mensajes) do
      add :nuevo_campo, :string
      modify :descripcion, :text
    end

    create table(:respuestas) do
      add :contenido, :text
      add :mensaje_id, references(:mensajes)

      timestamps()
    end
  end
end
