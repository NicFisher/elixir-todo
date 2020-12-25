defmodule Todo.Workers.ResetPasswordEmailWorker do
  alias Todo.Config
  alias Todo.{Accounts.ResetPasswordToken, Repo, Mailer.SendEmail}
  alias Ecto.Multi

  def new(token) do
    %{"type" => to_string(__MODULE__), "token" => token}
  end

  def enqueue(token) do
    new(token)
    |> Todo.JobQueue.new()
    |> Todo.Repo.insert()
  end

  def perform(%Ecto.Multi{} = multi, %{"token" => token}) do
    multi
    |> Multi.run(:reset_password_token, fn _, _ -> get_reset_password_token(token) end)
    |> Multi.run(:send_email, fn _, %{reset_password_token: reset_password_token} ->
      send_email(reset_password_token)
    end)
    |> Todo.Repo.transaction()
  end

  defp get_reset_password_token(token) do
    case Repo.get_by(ResetPasswordToken, token: token) |> Repo.preload([:user]) do
      nil -> {:error, "Unable to find reset password token"}
      reset_password_token -> {:ok, reset_password_token}
    end
  end

  defp send_email(%ResetPasswordToken{
         user: %{email: email, name: user_name},
         token: token
       }) do
    SendEmail.perform(email, user_name, email_subject(), email_content(token))
  end

  defp send_email(_) do
    {:error, "Invalid reset password token details"}
  end

  defp email_subject() do
    "Elixir Todo List - Reset Password"
  end

  defp email_content(token) do
    """
    <html>
    <head></head>
    <body>
    Please use the below link to reset your password.
    <br><br>

    #{Config.base_url()}/reset-password/reset?token=#{token}

    <br>
    Note: This link will expire in 24 hours.
    </body>
    </html>
    """
  end
end
