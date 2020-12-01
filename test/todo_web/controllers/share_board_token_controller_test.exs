defmodule Todo.ShareBoardTokens.CreateShareBoardTokenTest do
  use TodoWeb.ConnCase
  alias Todo.Accounts.{User, Guardian}
  alias Todo.Boards.ShareBoardToken
  alias Todo.Factory

  setup %{conn: conn} do
    {:ok, user} = Factory.create_user()

    auth_conn =
      conn
      |> Guardian.Plug.sign_in(%User{id: user.id})

    {:ok, auth_conn: auth_conn, conn: conn, user: user}
  end

  describe "new/2" do
    test "with user in session", %{auth_conn: auth_conn} do
      conn = get(auth_conn, "share-board/new")
      assert html_response(conn, 200) =~ "Share Board"
    end

    test "without user in session", %{conn: conn} do
      conn = get(conn, "share-board/new")
      assert conn.status == 401
    end
  end

  describe "index/2" do
    test "with user in session", %{auth_conn: auth_conn} do
      conn = get(auth_conn, "share-board")
      assert html_response(conn, 200) =~ "Share Board"
    end

    test "without user in session", %{conn: conn} do
      conn = get(conn, "share-board")
      assert conn.status == 401
    end
  end

  describe "create/2" do
    test "with valid params", %{auth_conn: auth_conn, user: user} do
      {:ok, board} = Factory.create_board(user, "First Board")
      {:ok, user2} = Factory.create_user("user2@email.com.au")

      params = %{
        "share_board_token" => %{
          "board_id" => board.id,
          "user_email" => user2.email
        }
      }

      post(auth_conn, "share-board", params)

      all_tokens = Todo.Repo.all(ShareBoardToken)
      new_token = List.first(all_tokens)

      assert new_token.board_id == board.id
      assert new_token.user_id == user2.id
      assert new_token.expiry_date < Timex.now() |> Timex.shift(days: 2)
    end

    test "without valid email in params", %{auth_conn: auth_conn, user: user} do
      {:ok, board} = Factory.create_board(user, "First Board")

      params = %{
        "share_board_token" => %{
          "board_id" => board.id,
          "user_email" => "random@email.com"
        }
      }

      conn = post(auth_conn, "share-board", params)

      assert html_response(conn, 200) =~ "User does not exist"
      assert html_response(conn, 200) =~ "Share Board"
    end

    test "without valid board in params", %{auth_conn: auth_conn} do
      {:ok, user2} = Factory.create_user("user2@email.com.au")

      params = %{
        "share_board_token" => %{
          "board_id" => "",
          "user_email" => user2.email
        }
      }

      conn = post(auth_conn, "share-board", params)

      assert html_response(conn, 200) =~ "Board must be selected"
      assert html_response(conn, 200) =~ "Share Board"
    end

    test "without user in session", %{conn: conn, user: user} do
      {:ok, board} = Factory.create_board(user, "First Board")
      {:ok, user2} = Factory.create_user("user2@email.com.au")

      params = %{
        "share_board_token" => %{
          "board_id" => board.id,
          "user_email" => user2.email
        }
      }

      conn = post(conn, "share-board", params)
      assert conn.status == 401
    end
  end
end
