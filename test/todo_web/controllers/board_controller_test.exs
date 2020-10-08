defmodule TodoWeb.BoardControllerTest do
  use TodoWeb.ConnCase
  alias Todo.Accounts.{User, Guardian}
  alias Todo.Boards.Board

  setup %{conn: conn} do
    Todo.Repo.insert(%User{
      id: "3f10cb63-122e-47f6-b987-2ee0b0e63446",
      email: "email@email.com",
      password: "password",
      name: "Joe Bloggs"
    })

    auth_conn =
      conn
      |> Guardian.Plug.sign_in(%User{id: "3f10cb63-122e-47f6-b987-2ee0b0e63446"})

    {:ok, auth_conn: auth_conn, conn: conn}
  end

  describe "GET board #new" do
    test "with user in session", %{auth_conn: auth_conn} do
      conn = get(auth_conn, "boards/new")
      assert html_response(conn, 200) =~ "New Board"
    end

    test "without user in session", %{conn: conn} do
      conn = get(conn, "boards/new")
      assert conn.status == 401
    end
  end

  describe "GET board #index" do
    test "with user in session", %{auth_conn: auth_conn} do
      Todo.Repo.insert(%Board{
        name: "First Board",
        user_id: "3f10cb63-122e-47f6-b987-2ee0b0e63446"
      })

      Todo.Repo.insert(%Board{
        name: "Second Board",
        user_id: "3f10cb63-122e-47f6-b987-2ee0b0e63446"
      })

      conn = get(auth_conn, "boards")
      assert html_response(conn, 200) =~ "First Board"
      assert html_response(conn, 200) =~ "Second Board"
    end

    test "without user in session", %{conn: conn} do
      conn = get(conn, "boards/new")
      assert conn.status == 401
    end
  end

  describe "POST board #create" do
    test "with matching params and user in session", %{auth_conn: auth_conn} do
      params = %{
        "board" => %{
          "name" => "First Board"
        }
      }

      conn = post(auth_conn, "boards", params)
      all_boards = Todo.Repo.all(Board)
      new_board = List.first(all_boards)

      assert new_board.name == "First Board"
      assert new_board.user_id == "3f10cb63-122e-47f6-b987-2ee0b0e63446"

      assert html_response(conn, 200) =~ "Board Created"
      assert html_response(conn, 200) =~ "First Board"
    end

    test "without name params and with user in session", %{auth_conn: auth_conn} do
      params = %{
        "board" => %{}
      }

      conn = post(auth_conn, "boards", params)

      assert html_response(conn, 200) =~ "Oops, something went wrong."
      assert html_response(conn, 200) =~ "New Board"
    end

    test "without name params and without user in session", %{conn: conn} do
      params = %{
        "board" => %{}
      }

      conn = post(conn, "boards", params)
      assert conn.status == 401
    end
  end

  describe "GET board #edit" do
    test "with user in session", %{auth_conn: auth_conn} do
      {:ok, board} =
        Todo.Repo.insert(%Board{
          name: "First Board",
          user_id: "3f10cb63-122e-47f6-b987-2ee0b0e63446"
        })

      conn = get(auth_conn, "boards/#{board.id}/edit")

      assert html_response(conn, 200) =~ "Update Board"
      assert html_response(conn, 200) =~ "First Board"
    end

    test "without name params and with user in session", %{conn: conn} do
      {:ok, board} =
        Todo.Repo.insert(%Board{
          name: "First Board",
          user_id: "3f10cb63-122e-47f6-b987-2ee0b0e63446"
        })

      conn = get(conn, "boards/#{board.id}/edit")

      assert conn.status == 401
    end
  end

  describe "PUT board #edit" do
    test "with valid params and user in session", %{auth_conn: auth_conn} do
      {:ok, board} =
        Todo.Repo.insert(%Board{
          name: "First Board",
          user_id: "3f10cb63-122e-47f6-b987-2ee0b0e63446"
        })

      params = %{
        "board" => %{
          "name" => "Updated First Board"
        }
      }

      conn = patch(auth_conn, "boards/#{board.id}", params)
      assert redirected_to(conn) == Routes.board_path(conn, :index)
    end

    test "with invalid params and user in session", %{auth_conn: auth_conn} do
      {:ok, board} =
        Todo.Repo.insert(%Board{
          name: "First Board",
          user_id: "3f10cb63-122e-47f6-b987-2ee0b0e63446"
        })

      params = %{
        "board" => %{
          "name" => ""
        }
      }

      conn = patch(auth_conn, "boards/#{board.id}", params)
      assert html_response(conn, 200) =~ "Invalid details."
    end

    test "with board for another user", %{auth_conn: auth_conn} do
      Todo.Repo.insert(%Board{
        name: "First Board",
        user_id: "3f10cb63-122e-47f6-b987-2ee0b0e63446"
      })

      {:ok, another_user} =
        Todo.Repo.insert(%User{
          email: "another_email@email.com",
          password: "password",
          name: "Joe Bloggs"
        })

      {:ok, board} =
        Todo.Repo.insert(%Board{
          name: "Invalid Board",
          user_id: another_user.id
        })

      params = %{
        "board" => %{
          "name" => "Updated First Board"
        }
      }

      assert_raise Ecto.NoResultsError,
                   ~r/^expected at least one result but got none in query/,
                   fn ->
                     put(auth_conn, "boards/#{board.id}", params)
                   end
    end
  end
end
