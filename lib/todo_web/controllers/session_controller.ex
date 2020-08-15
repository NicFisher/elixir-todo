defmodule TodoWeb.SessionController do
  use TodoWeb, :controller

  alias Todo.{Accounts, Accounts.User, Accounts.Guardian}

  def new(conn, _) do
    if user(conn) do
      redirect(conn, to: "/boards")
    else
      changeset = Accounts.change_user(%User{})
      render(conn, "new.html", changeset: changeset)
    end
  end

  def login(conn, %{"user" => %{"email" => email, "password" => password}}) do
    Accounts.authenticate_user(email, password)
    |> login_reply(conn)
  end

  def logout(conn, _) do
    conn
    |> Guardian.Plug.sign_out()
    |> redirect(to: Routes.session_path(conn, :login))
  end

  defp user(conn) do
    Guardian.Plug.current_resource(conn)
  end

  defp login_reply({:ok, user}, conn) do
    conn
    |> Guardian.Plug.sign_in(user)
    |> redirect(to: "/boards")
  end

  defp login_reply({:error, :invalid_credentials}, conn) do
    conn
    |> put_flash(:error, "Invalid login details")
    |> new(%{})
  end
end
