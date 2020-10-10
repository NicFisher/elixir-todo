defmodule TodoWeb.ListControllerTest do
  use TodoWeb.ConnCase
  alias Todo.Accounts.{User, Guardian}
  alias Todo.Boards.{Board}

  setup %{conn: conn} do
    Todo.Repo.insert(%User{
      id: "3f10cb63-122e-47f6-b987-2ee0b0e63446",
      email: "email@email.com",
      password: "password",
      name: "Joe Bloggs"
    })

    {:ok, board} =
      Todo.Repo.insert(%Board{
        name: "First Board",
        user_id: "3f10cb63-122e-47f6-b987-2ee0b0e63446"
      })

    auth_conn =
      conn
      |> Guardian.Plug.sign_in(%User{id: "3f10cb63-122e-47f6-b987-2ee0b0e63446"})

    {:ok, auth_conn: auth_conn, conn: conn, board: board}
  end

  describe "GET list #new" do
    test "with user in session returns new list page", %{auth_conn: auth_conn, board: board} do
      conn = get(auth_conn, "boards/#{board.id}/list/new")
      assert html_response(conn, 200) =~ "New List"
    end

    test "without user in session returns unauthorized error", %{conn: conn, board: board} do
      conn = get(conn, "boards/#{board.id}/list/new")
      assert conn.status == 401
    end
  end

  describe "POST list #create" do
    test "with matching params and user in session creates new list and redirects to board show",
         %{auth_conn: auth_conn, board: board} do
      params = %{
        "board_id" => board.id,
        "list" => %{
          "name" => "Doing",
          "position" => "1",
          "archived" => false
        }
      }

      conn = post(auth_conn, "boards/#{board.id}/list", params)
      all_lists = Todo.Repo.all(Todo.Boards.List)
      new_list_board = List.first(all_lists)

      assert new_list_board.name == "Doing"
      assert new_list_board.board_id == board.id
      assert new_list_board.position == 1
      assert new_list_board.archived == false

      assert redirected_to(conn) == "/boards/#{board.id}"
    end

    test "without valid params and with user in session returns error", %{
      auth_conn: auth_conn,
      board: board
    } do
      params = %{
        "board_id" => board.id,
        "list" => %{
          "position" => "1",
          "archived" => false
        }
      }

      conn = post(auth_conn, "boards/#{board.id}/list", params)

      assert html_response(conn, 200) =~ "Invalid details"
      assert html_response(conn, 200) =~ "New List"
    end

    test "without valid params and without user in session returns unauthorized error", %{
      conn: conn,
      board: board
    } do
      params = %{
        "board_id" => board.id,
        "list" => %{
          "position" => "1",
          "archived" => false
        }
      }

      conn = post(conn, "boards/#{board.id}/list", params)
      assert conn.status == 401
    end
  end

  describe "GET list #edit" do
    test "with user in session returns edit page with list in details in fields", %{
      auth_conn: auth_conn,
      board: board
    } do
      {:ok, list} =
        Todo.Repo.insert(%Todo.Boards.List{
          name: "Done",
          position: 4,
          archived: false,
          board_id: board.id
        })

      conn = get(auth_conn, "boards/#{board.id}/list/#{list.id}/edit")

      assert html_response(conn, 200) =~ "Update List"
      assert html_response(conn, 200) =~ "Done"
    end

    test "without user in session returns unauthorized error", %{conn: conn, board: board} do
      {:ok, list} =
        Todo.Repo.insert(%Todo.Boards.List{
          name: "Done",
          position: 4,
          archived: false,
          board_id: board.id
        })

      conn = get(conn, "boards/#{board.id}/list/#{list.id}/edit")

      assert conn.status == 401
    end
  end

  describe "PUT board #edit" do
    test "with valid params and user in session updates list and redirects to board show page",
         %{auth_conn: auth_conn, board: board} do
      {:ok, list} =
        Todo.Repo.insert(%Todo.Boards.List{
          name: "Done",
          position: 4,
          archived: false,
          board_id: board.id
        })

      params = %{
        "board_id" => board.id,
        "list" => %{
          "name" => "Done",
          "position" => "3",
          "archived" => false
        }
      }

      conn = put(auth_conn, "boards/#{board.id}/list/#{list.id}", params)

      all_lists = Todo.Repo.all(Todo.Boards.List)
      new_list_board = List.first(all_lists)

      assert new_list_board.name == "Done"
      assert new_list_board.board_id == board.id
      assert new_list_board.position == 3
      assert new_list_board.archived == false

      assert redirected_to(conn) == "/boards/#{board.id}"
    end

    test "with invalid params and user in session returns invalid details error", %{
      auth_conn: auth_conn,
      board: board
    } do
      {:ok, list} =
        Todo.Repo.insert(%Todo.Boards.List{
          name: "Done",
          position: 4,
          archived: false,
          board_id: board.id
        })

      params = %{
        "board_id" => board.id,
        "list" => %{
          "name" => "",
          "position" => "3",
          "archived" => false
        }
      }

      conn = put(auth_conn, "boards/#{board.id}/list/#{list.id}", params)
      assert html_response(conn, 200) =~ "Invalid details."
    end

    test "without user in session returns unauthorized error", %{conn: conn, board: board} do
      {:ok, list} =
        Todo.Repo.insert(%Todo.Boards.List{
          name: "Done",
          position: 4,
          archived: false,
          board_id: board.id
        })

      params = %{
        "board_id" => board.id,
        "list" => %{
          "name" => "New Name",
          "position" => "3",
          "archived" => false
        }
      }

      conn = put(conn, "boards/#{board.id}/list/#{list.id}", params)
      assert conn.status == 401
    end
  end
end
