defmodule TodoWeb.ResetPasswordTokenController do
  use TodoWeb, :controller
  alias Todo.Accounts
  alias Ecto.Multi
  alias Todo.Accounts.{ResetPasswordToken, User, ResetPasswordToken.CreateResetPasswordToken}

  def new(conn, _params) do
    render_new(conn)
  end

  def create(conn, %{"reset_password_token" => %{"email" => email}}) do
    with {:ok, _} <- CreateResetPasswordToken.create(email) do
      conn
      |> put_flash(:info, "Reset password email has been sent to #{email}")
      |> render_new
    else
      {:error, message} ->
        conn
        |> put_flash(:error, message)
        |> render_new
    end
  end

  def reset(conn, %{"token" => token}) do
    with {:ok, %ResetPasswordToken{user: user}} <- ResetPasswordToken.validate(token) do
      conn
      |> render("reset.html", changeset: Accounts.change_user(user), token: token)
    else
      {:error, message} ->
        conn
        |> put_flash(:error, message)
        |> render_new
    end
  end

  def update(conn, %{"token" => token, "user" => %{"password" => new_password}}) do
    with {:ok, reset_password_token} <- ResetPasswordToken.validate(token),
         {:ok, _} <- update_user_and_reset_password_token(reset_password_token, new_password) do
      conn
      |> put_flash(:info, "Password has been reset.")
      |> redirect(to: "/login")
    else
      {:error, message} ->
        conn
        |> put_flash(:error, message)
        |> render_new
    end
  end

  defp render_new(conn) do
    render(conn, "new.html",
      changeset: Accounts.change_reset_password_token(%ResetPasswordToken{})
    )
  end

  defp update_user_and_reset_password_token(reset_password_token, new_password) do
    Multi.new
    |> Multi.update(:reset_password_token, Accounts.change_reset_password_token(reset_password_token, %{used: true}))
    |> Multi.update(:user, Accounts.change_user(reset_password_token.user, %{password: new_password}))
    |> Todo.Repo.transaction()
  end
end
