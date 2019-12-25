defmodule Echoes.User do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query
  alias Echoes.{Repo, User, Blacklist, Membership, Chat}

  schema "users" do
    field :active, :boolean, default: true
    field :avatar_origin, :string
    field :avatar_url, :string
    field :banned, :boolean, default: false
    field :email, :string
    field :last_online_at, :utc_datetime
    field :name, :string
    field :password_hash, :string
    field :username, :string

    timestamps()
  end

  def create(name, email, username, password) do
    {_, dt} = Ecto.Type.cast(:utc_datetime, DateTime.utc_now)
    with {_, user} = Repo.insert(
      %User{
        username: username,
        name: name,
        email: email,
        password_hash: Bcrypt.hash_pwd_salt(password),
        last_online_at: dt
      }
    ) do
      user
    end
  end

  def blacklisted(user_id, target_user_id) do
    Repo.one(
      from b in Blacklist,
        where: b.owner_id == ^user_id,
        where: b.user_id == ^target_user_id,
        select: count(b.id)
    )
  end

  def add_to_blacklist(user_id, target_user_id) do
    case blacklisted(user_id, target_user_id) do
      0 ->
        Repo.insert(
          %Blacklist{
            owner_id: user_id,
            user_id: target_user_id
          }
        )
        set_dialog_ban_status(user_id, target_user_id, true)

      _ ->
        nil
    end
  end

  def remove_from_blacklist(user_id, target_user_id) do
    query = from b in Blacklist,
                 where: b.owner_id == ^user_id,
                 where: b.user_id == ^target_user_id

    case Repo.one(query) do
      nil ->
        false

      bl ->
        Repo.delete(bl)
        set_dialog_ban_status(user_id, target_user_id, false)
        true
    end
  end

  def find_alike(pattern, offset_value, limit_value) do
    Repo.all(
      from u in User,
        where: like(u.username, ^"%#{String.replace(pattern, "%", "\\%")}%"),
        offset: ^offset_value,
        limit: ^limit_value
    )
  end

  defp set_dialog_ban_status(user_id, target_user_id, status) do
    query = from m in Membership,
                 inner_join: c in Chat, on: m.chat_id == c.id,
                 inner_join: m2 in Membership, on: m2.chat_id == c.id and m2.user_id == ^target_user_id,
                 where: c.type == "dialog",
                 where: m2.chat_id == m.chat_id,
                 where: m.user_id == ^user_id,
                 group_by: m2.id,
                 select: m2

    case Repo.all(query) do
      [] ->
        nil
      memberships ->
        Enum.each(memberships, fn(membership) ->
          Membership.changeset(memberships, %{banned: status})
          |> Repo.update()
        end)
    end
  end

  def check_errors(email, username) do
    username_taken(username) ++ email_taken(email)
  end

  def update_last_online(user) do
    {status, user} = user
      |> Ecto.Changeset.change
      |> Ecto.Changeset.put_change(:last_online_at, DateTime.utc_now)
      |> Repo.update()
  end

  def change_username(user, new_username) do
    change_user(user, %{username: new_username})
  end

  def change_email(user, new_email) do
    change_user(user, %{email: new_email})
  end

  def change_name(user, new_name) do
    change_user(user, %{name: new_name})
  end

  def change_password(user, new_password) do
    change_user(user, %{password_hash: Bcrypt.hash_pwd_salt(new_password)})
  end

  defp change_user(user, changes) do
    {status, payload} =
      Ecto.Changeset.change(user, changes)
      |> Repo.update()

    case status do
      :ok -> payload
      :error -> nil
    end
  end

  def get_by_credentials(username, password) do
    case Repo.get_by(User, username: username) do
      nil -> {:error, nil}
      user ->
        case check_password(user, password) do
          false -> {:error, user}
          true  -> {:ok,    user}
        end
    end
  end

  defp email_taken(email) do
    query = from u in User, select: count(u.id), where: u.email == ^email

    case Repo.one(query) do
      0 -> []
      _ -> [%{field: "email", error: "taken"}]
    end
  end

  defp username_taken(username) do
    query = from u in User, select: count(u.id), where: u.username == ^username

    case Repo.one(query) do
      0 -> []
      _ -> [%{field: "username", error: "taken"}]
    end
  end

  def check_password(%User{password_hash: hash}, password) do
    _check_password(hash, password)
  end

  def check_password(user_id, password) do
    case Repo.get(User, user_id) do
      nil  -> false
      user -> _check_password(user.password_hash, password)
    end
  end

  defp _check_password(password_hash, password) do
    Bcrypt.verify_pass(password, password_hash)
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:avatar_url, :avatar_origin, :username, :email, :name, :password_hash, :last_online_at, :active, :banned])
    |> validate_required([:avatar_url, :avatar_origin, :username, :email, :name, :password_hash, :last_online_at, :active, :banned])
    |> unique_constraint([:email, :username])
  end
end
