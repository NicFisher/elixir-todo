defmodule Todo.Accounts.Guardian do
  use Guardian, otp_app: :todo

  alias Todo.Accounts

  # subject_for_token and resource_from_claims are inverses of one
  # another. subject_for_token is used to encode the User into the
  # token, and resource_from_claims is used to rehydrate the User
  # from the claims.

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
