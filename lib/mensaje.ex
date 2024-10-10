defmodule ElixirChat.Mensaje do
  use Ecto.Schema
  import Ecto.Changeset

  schema "mensajes" do
    field :descripcion, :string
    field :fecha, :utc_datetime

    timestamps()
  end

  def changeset(mensaje, attrs) do
    mensaje
    |> cast(attrs, [:descripcion, :fecha])
    |> validate_required([:descripcion, :fecha])
  end
end
