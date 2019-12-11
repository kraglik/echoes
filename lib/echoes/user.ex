defmodule Echoes.User do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query
  alias Echoes.{Repo, User}

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
    Repo.insert(
      %User{
        username: username,
        name: name,
        email: email,
        password_hash: Bcrypt.hash_pwd_salt(password),
        last_online_at: dt
      }
    )
  end

  def check_errors(email, username) do
    username_taken(username) ++ email_taken(email)
  end

  def change_password(user, password) do
    user
      |> Ecto.Changeset.change
      |> Ecto.Changeset.put_change(:password_hash, Bcrypt.hash_pwd_salt(password))
      |> Repo.update()
  end

  def update_last_online(user) do
    with {_, dt} = Ecto.Type.cast(:utc_datetime, DateTime.utc_now) do
      {status, user} = user
        |> Ecto.Changeset.change
        |> Ecto.Changeset.put_change(:last_online_at, dt)
        |> Repo.update()
    end
  end

  def change_username(user, new_username) do
    {_, last_online_at} = Ecto.Type.cast(:utc_datetime, DateTime.utc_now)
    {status, payload} =
      Ecto.Changeset.change(user, %{username: new_username})
        |> Repo.update()

    case status do
      :ok -> payload
      :error -> nil
    end
  end

  def change_password(user, new_password) do
    password_hash = Bcrypt.hash_pwd_salt new_password
    {_, last_online_at} = Ecto.Type.cast(:utc_datetime, DateTime.utc_now)

    {status, payload} =
      Ecto.Changeset.change(user, %{password_hash: password_hash})
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
