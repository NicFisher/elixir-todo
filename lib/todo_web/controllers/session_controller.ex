defmodule TodoWeb.SessionController do
  use TodoWeb, :controller

  alias Todo.{Accounts, Accounts.User, Accounts.Guardian}

  def new(conn, _) do
    changeset = Accounts.change_user(%User{})
    user = Guardian.Plug.current_resource(conn)

    if user do
      redirect(conn, to: "/protected")
    else
      render(conn, "new.html", changeset: changeset)
    end
  end

  @spec login(Plug.Conn.t(), map) :: Plug.Conn.t()
  def login(conn, %{"user" => %{"username" => username, "password" => password}}) do
    Accounts.authenticate_user(username, password)
    |> login_reply(conn)
  end

  def logout(conn, _) do
    conn
    |> Guardian.Plug.sign_out()
    |> redirect(to: "/login")
  end

  defp login_reply({:ok, user}, conn) do
    conn
    |> put_flash(:info, "Welcome back!")
    |> Guardian.Plug.sign_in(user)
    |> redirect(to: "/protected")
  end

  defp login_reply({:error, reason}, conn) do
    conn
    |> put_flash(:error, to_string(reason))
    |> new(%{})
  end
end
