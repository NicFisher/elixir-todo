defmodule TodoWeb.UserController do
  use TodoWeb, :controller
  alias Todo.{Accounts, Accounts.User, Accounts.Guardian}

  def new(conn, _params) do
    case Guardian.Plug.current_resource(conn) do
      %User{} -> redirect(conn, to: "/protected")
      nil -> render(conn, "new.html", changeset: Accounts.change_user(%User{}))
    end
  end

  def create(conn, %{"user" => %{"email" => email, "password" => password, "name" => name}}) do
    case Accounts.create_user(%{"email" => email, "password" => password, "name" => name}) do
      {:ok, _user} ->
        Accounts.authenticate_user(email, password) |> login_user(conn)

      {:error, changeset} ->
        conn |> put_flash(:error, "Invalid details.") |> render("new.html", changeset: changeset)

      nil ->
        conn |> put_flash(:error, "Invalid details.") |> new(%{})
    end
  end

  def create(conn, _params) do
    conn
    |> put_flash(:error, "Invalid details.")
    |> new(%{})
  end

  def edit(conn, _params) do
    current_user = Guardian.Plug.current_resource(conn)
    changeset = Accounts.change_user(current_user)

    render(conn, "edit.html", changeset: changeset, current_user: current_user)
  end

  def update(conn, %{"user" => user}) do
    case update_user(conn, user) do
      {:ok, _user} ->
        conn
        |> put_flash(:info, "User Updated")
        |> redirect(to: "/protected")

      {:error, changeset} ->
        conn
        |> put_flash(:error, "Invalid details.")
        |> render("edit.html", changeset: changeset, user: Guardian.Plug.current_resource(conn))
    end
  end

  defp login_user({:ok, user}, conn) do
    conn
    |> put_flash(:info, "Welcome!")
    |> Guardian.Plug.sign_in(user)
    |> redirect(to: "/protected")
  end

  defp login_user({:error, :invalid_credentials}, conn) do
    conn
    |> put_flash(:error, "Oops, something went wrong.")
    |> new(%{})
  end

  defp update_user(conn, user) do
    Guardian.Plug.current_resource(conn)
    |> Accounts.update_user(user)
  end
end
