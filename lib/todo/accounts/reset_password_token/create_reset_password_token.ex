defmodule Todo.Accounts.ResetPasswordToken.CreateResetPasswordToken do
  alias Todo.{Accounts, Accounts.User}
  alias Todo.Workers.ResetPasswordEmailWorker
  alias Todo.Repo

  def create(email) do
    with {:ok, user} <- get_user(email),
         {:ok, reset_password_token} <- Accounts.create_reset_password_token(user.id),
         {:ok, _} <- enqueue_reset_password_email_worker(reset_password_token.token) do
      {:ok, reset_password_token}
    else
      {:error, error} -> {:error, error}
      _ -> {:error, "Unable to send reset password email"}
    end
  end

  defp get_user(email) do
    case Repo.get_by(User, email: email) do
      nil -> {:error, "User does not exist."}
      user -> {:ok, user}
    end
  end

  defp enqueue_reset_password_email_worker(token) do
    ResetPasswordEmailWorker.enqueue(token)
  end
end
