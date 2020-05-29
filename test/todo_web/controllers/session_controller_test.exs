defmodule TodoWeb.SessionControllerTest do
  use TodoWeb.ConnCase
  alias Todo.Accounts

  describe "GET /login" do
    @valid_attrs %{password: "some password", username: "some username"}

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

    # test "with user returns login page", %{conn: conn} do
      # can't figure how to set this up
      # require IEx; IEx.pry;
    # end
  end

  describe "POST /login" do
    test "with valid params returns protected page", %{conn: conn} do
      user_fixture()
      conn = post(conn, "/login", user: @valid_attrs)
      assert redirected_to(conn) == Routes.page_path(conn, :protected)
    end

    test "with invalid params returns protected page", %{conn: conn} do
      conn = post(conn, "/login", user: %{password: "invalid password", username: "invalid username"})
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
