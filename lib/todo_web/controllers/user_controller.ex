defmodule TodoWeb.UserController do
  use TodoWeb, :controller
  alias Todo.{Accounts, Accounts.User, Accounts.Guardian}

  def new(conn, _params) do
    with %User{} <- Guardian.Plug.current_resource(conn) do
      redirect(conn, to: "/protected")
    else
      nil -> render(conn, "new.html", changeset: Accounts.change_user(%User{}))
    end
  end

  def create(conn, %{"user" => %{"username" => username, "password" => password, "name" => name}}) do
    with {:ok, _user} <- Accounts.create_user(%{"username" => username, "password" => password, "name" => name}) do
      Accounts.authenticate_user(username, password)
      |> login_user(conn)
    else
      nil -> conn |> put_flash(:error, "Invalid details.") |> new(%{})
    end
  end

  def create(conn, _params) do
    conn
    |> put_flash(:error, "Invalid details.")
    |> new(%{})
  end

  defp login_user({:ok, user}, conn) do
    conn
    |> put_flash(:info, "Welcome!")
    |> Guardian.Plug.sign_in(user)
    |> redirect(to: "/protected")
  end

  defp login_user({:error, :invalid_credentials}, conn) do
    conn
    |> put_flash(:error, "Opps, something went wrong.")
    |> new(%{})
  end
end
