defmodule Echoes.MessageRead do
  use Ecto.Schema
  import Ecto.Changeset

  @timestamps_opts [type: :utc_datetime_usec]
  schema "message_reads" do
    field :user_id, :id
    field :message_id, :id

    timestamps()
  end

  @doc false
  def changeset(message_read, attrs) do
    message_read
    |> cast(attrs, [])
    |> validate_required([])
  end
end
