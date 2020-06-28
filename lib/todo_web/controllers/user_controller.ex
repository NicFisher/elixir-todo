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

  def create(conn, %{"user" => %{"email" => email, "password" => password, "name" => name}}) do
    with {:ok, _user} <- Accounts.create_user(%{"email" => email, "password" => password, "name" => name}) do
      Accounts.authenticate_user(email, password)
      |> login_user(conn)
    else
      {:error, changeset} ->
        conn
        |> put_flash(:error, "Invalid details.")
        |> render("new.html", changeset: changeset)
      nil -> conn |> put_flash(:error, "Invalid details.") |> new(%{})
    end
  end

  def create(conn, _params) do
    conn
    |> put_flash(:error, "Invalid details.")
    |> new(%{})
  end

  def edit(conn, _params) do
    user = Guardian.Plug.current_resource(conn)
    changeset = Accounts.change_user(user)

    render conn, "edit.html", changeset: changeset, user: user
  end

  def update(conn, %{"user" => user}) do
    case update_user(conn, user) do
      {:ok, _user} ->
        conn
        |> put_flash(:info, "User Updated")
        |> redirect(to: "/protected")
      {:error, changeset} ->
        require IEx; IEx.pry
        render conn, "edit.html", changeset: changeset, user: Guardian.Plug.current_resource(conn)
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
    |> put_flash(:error, "Opps, something went wrong.")
    |> new(%{})
  end

  defp update_user(conn, user) do
    Guardian.Plug.current_resource(conn)
    |> Accounts.update_user(user)
  end
end
