defmodule Echoes.Guardian do
  use Guardian, otp_app: :echoes

  alias Echoes.{Repo, User}

  def subject_for_token(%User{id: id}, _claims) do
    {:ok, id}
  end

  def subject_for_token(_, _) do
    {:error, "wrong data"}
  end

  def resource_from_claims(claims) do
    case Repo.get(User, claims["sub"]) do
      nil  -> {:error, "user not found"}
      user -> {:ok, user}
    end
  end
end