defmodule TodoWeb.SessionControllerTest do
  use TodoWeb.ConnCase
  alias Todo.{Accounts, Accounts.User, Accounts.Guardian}

  setup %{conn: conn} do
    auth_conn =
      conn
      |> Guardian.Plug.sign_in(%User{id: "3f10cb63-122e-47f6-b987-2ee0b0e63446"})

    {:ok, auth_conn: auth_conn, conn: conn}
  end

  describe "GET /login" do
    @valid_attrs %{password: "some password", email: "email@email.com", name: "Joe Bloggs"}

    def user_fixture(attrs \\ %{}) do
      {:ok, user} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Accounts.create_user()

      user
    end

    test "without user returns login page", %{conn: conn} do
      conn = get(conn, "/login")
      assert html_response(conn, 200) =~ "Login Page"
    end

    test "with user returns protected page", %{auth_conn: auth_conn} do
      Todo.Repo.insert(%User{
        id: "3f10cb63-122e-47f6-b987-2ee0b0e63446",
        email: "email@email.com",
        password: "password",
        name: "Joe Bloggs"
      })

      conn = get(auth_conn, "/login")
      assert redirected_to(conn) == Routes.page_path(conn, :protected)
    end
  end

  describe "POST /login" do
    test "with valid params returns protected page", %{conn: conn} do
      user_fixture()
      conn = post(conn, "/login", user: @valid_attrs)
      assert redirected_to(conn) == Routes.page_path(conn, :protected)
    end

    test "with invalid params returns protected page", %{conn: conn} do
      conn =
        post(conn, "/login", user: %{password: "invalid password", email: "invalid@email.com"})

      assert html_response(conn, 200) =~ "Invalid login details"
    end
  end

  describe "POST /logout" do
    test "redirect to login page", %{conn: conn} do
      conn = post(conn, "/logout")
      assert redirected_to(conn) == Routes.session_path(conn, :login)
    end
  end
end
