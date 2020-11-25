defmodule TodoWeb.SharedBoard.BoardControllerTest do
  use TodoWeb.ConnCase
  alias Todo.Accounts.{User, Guardian}
  alias Todo.Boards.{Board, BoardUser}

  setup %{conn: conn} do
    {:ok, user} =
      Todo.Repo.insert(%User{
        email: "email@email.com",
        password: "password",
        name: "Joe Bloggs"
      })

    {:ok, board} =
      Todo.Repo.insert(%Board{
        name: "First Board",
        user_id: user.id
      })

    Todo.Repo.insert(%BoardUser{
      user_id: user.id,
      board_id: board.id
    })

    auth_conn =
      conn
      |> Guardian.Plug.sign_in(%User{id: user.id})

    {:ok, auth_conn: auth_conn, conn: conn, user: user, board: board}
  end

  describe "GET board #index" do
    test "with user in session", %{auth_conn: auth_conn} do
      conn = get(auth_conn, "shared-boards/boards")
      assert html_response(conn, 200) =~ "First Board"
    end

    test "without user in session", %{conn: conn} do
      conn = get(conn, "shared-boards/boards")
      assert conn.status == 401
    end
  end

  describe "GET board #edit" do
    test "with user in session", %{auth_conn: auth_conn, board: board} do
      conn = get(auth_conn, "shared-boards/boards/#{board.id}/edit")

      assert html_response(conn, 200) =~ "Update Board"
      assert html_response(conn, 200) =~ "First Board"
    end

    test "without name params and with user in session", %{conn: conn, board: board} do
      conn = get(conn, "shared-boards/boards/#{board.id}/edit")

      assert conn.status == 401
    end
  end

  describe "PUT board #edit" do
    test "with valid params and user in session", %{auth_conn: auth_conn, board: board} do
      params = %{
        "board" => %{
          "name" => "Updated First Board"
        }
      }

      conn = patch(auth_conn, "shared-boards/boards/#{board.id}", params)
      assert redirected_to(conn) == Routes.shared_board_path(conn, :index)
    end

    test "with invalid params and user in session", %{auth_conn: auth_conn, board: board} do
      params = %{
        "board" => %{
          "name" => ""
        }
      }

      conn = patch(auth_conn, "shared-boards/boards/#{board.id}", params)
      assert html_response(conn, 200) =~ "Invalid details."
    end

    test "with board for another user", %{auth_conn: auth_conn} do
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
                     put(auth_conn, "shared-boards/boards/#{board.id}", params)
                   end
    end
  end
end
