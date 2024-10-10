defmodule ElixirChat.Mensaje do
  use Ecto.Schema
  import Ecto.Changeset

  schema "mensajes" do
    field :body, :string
    field :fecha, :utc_datetime

    timestamps()
  end

  def changeset(mensaje, attrs) do
    mensaje
    |> cast(attrs, [:body, :fecha])
    |> validate_required([:body, :fecha])
  end
end
