defmodule TodoWeb.SessionController do
  use TodoWeb, :controller

  alias Todo.{Accounts, Accounts.User, Accounts.Guardian}

  def new(conn, _) do
    if user(conn) do
      redirect(conn, to: "/protected")
    else
      changeset = Accounts.change_user(%User{})
      render(conn, "new.html", changeset: changeset)
    end
  end

  def login(conn, %{"user" => %{"username" => username, "password" => password}}) do
    Accounts.authenticate_user(username, password)
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
    |> put_flash(:info, "Welcome back!")
    |> Guardian.Plug.sign_in(user)
    |> redirect(to: "/protected")
  end

  defp login_reply({:error, :invalid_credentials}, conn) do
    conn
    |> put_flash(:error, "Invalid login details")
    |> new(%{})
  end
end
