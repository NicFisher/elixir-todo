defmodule Todo.Accounts.Guardian do
  use Guardian, otp_app: :todo

  alias Todo.Accounts
  alias Todo.Accounts.Guardian

  # subject_for_token and resource_from_claims are inverses of one
  # another. subject_for_token is used to encode the User into the
  # token, and resource_from_claims is used to rehydrate the User
  # from the claims.

  def user_from_token(token) do
    {:ok, claims} = Guardian.decode_and_verify(token)
    Guardian.resource_from_claims(claims)
  end

  def subject_for_token(user, _claims) do
    {:ok, to_string(user.id)}
  end

  def resource_from_claims(%{"sub" => id}) do
    user = Accounts.get_user!(id)
    {:ok, user}
  rescue
    Ecto.NoResultsError -> {:error, :resource_not_found}
  end
end
