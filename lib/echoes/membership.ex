defmodule Echoes.Membership do
  use Ecto.Schema
  import Ecto.Query
  import Ecto.Changeset

  alias Echoes.{Repo, Membership}

  schema "memberships" do
    field :active, :boolean, default: true
    field :banned, :boolean, default: false
    field :denied, :boolean, default: false
    field :moderator, :boolean, default: false
    field :owner, :boolean, default: false
    field :pin_order, :integer
    field :user_id, :id
    field :chat_id, :id

    timestamps()
  end

  def get(chat_id, user_id) do
    query = from m in Membership,
                 where: m.user_id == ^user_id,
                 where: m.chat_id == ^chat_id,
                 where: m.active and not m.banned and not m.denied
    Repo.one(query)
  end

  def exist(chat_id, user_id) do
    query = from m in Membership,
                 select: count(m.id),
                 where: m.user_id == ^user_id,
                 where: m.chat_id == ^chat_id,
                 where: m.active and not m.banned and not m.denied

    case Repo.one(query) do
      0 -> false
      _ -> true
    end
  end

  def can_post?(user_id, membership_id) do
    # TODO: implement
    true
  end

  @doc false
  def changeset(membership, attrs) do
    membership
    |> cast(attrs, [:active, :banned, :denied, :pin_order, :owner, :moderator])
    |> validate_required([:active, :banned, :denied, :pin_order, :owner, :moderator])
  end
end
