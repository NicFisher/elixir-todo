defmodule TodoWeb.UserControllerTest do
  use TodoWeb.ConnCase
  alias Todo.Accounts.{User, Guardian}

  setup %{conn: conn} do
    auth_conn =
      conn
      |> Guardian.Plug.sign_in(%User{id: "3f10cb63-122e-47f6-b987-2ee0b0e63446"})

    {:ok, auth_conn: auth_conn, conn: conn}
  end

  describe "GET user #new" do
    test "with user in session", %{auth_conn: auth_conn} do
      Todo.Repo.insert(%User{
        id: "3f10cb63-122e-47f6-b987-2ee0b0e63446",
        email: "email@email.com",
        password: "password",
        name: "Joe Bloggs"
      })

      conn = get(auth_conn, "users/new")
      assert redirected_to(conn) == Routes.page_path(conn, :protected)
    end

    test "without user in session", %{conn: conn} do
      conn = get(conn, "users/new")
      assert html_response(conn, 200) =~ "Create Account"
    end
  end

  describe "POST user #create" do
    test "with matching params", %{conn: conn} do
      params = %{
        "user" => %{
          "email" => "newuser@email.com",
          "password" => "password",
          "name" => "John Smith"
        }
      }

      conn = post(conn, "users", params)
      all_users = Todo.Repo.all(User)
      new_user = List.first(all_users)

      assert new_user.email == "newuser@email.com"
      assert new_user.name == "John Smith"

      assert redirected_to(conn) == Routes.page_path(conn, :protected)
    end

    test "with matching params but non unqiue email", %{conn: conn} do
      Todo.Repo.insert(%User{
        id: "3f10cb63-122e-47f6-b987-2ee0b0e63446",
        email: "email@email.com",
        password: "password",
        name: "Joe Bloggs"
      })

      params = %{
        "user" => %{
          "email" => "email@email.com",
          "password" => "password",
          "name" => "John Smith"
        }
      }

      conn = post(conn, "users", params)

      assert html_response(conn, 200) =~ "Create Account"
      assert html_response(conn, 200) =~ "Invalid details."
    end

    test "with missing params", %{conn: conn} do
      conn = post(conn, "users", %{})
      assert html_response(conn, 200) =~ "Create Account"
    end
  end
end
