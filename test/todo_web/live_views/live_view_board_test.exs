defmodule TodoWeb.LiveViewBoardTest do
  use TodoWeb.ConnCase
  alias Todo.Accounts.{User, Guardian}
  alias Todo.Accounts
  alias Todo.Repo
  alias Todo.Boards.Board
  import Plug.Conn
  import Phoenix.ConnTest
  import Phoenix.LiveViewTest
  alias Todo.Factory

  setup %{conn: conn} do
    {:ok, user} = Factory.create_user()

    Accounts.authenticate_user("email@email.com", "password")

    auth_conn =
      conn
      |> guardian_sign_in_user(user.id)
      |> add_token_to_session()

    {:ok, auth_conn: auth_conn, conn: conn, user: user}
  end

  test "displays board, board list and cards", %{auth_conn: auth_conn, user: user} do
    {:ok, board} = Factory.create_board(user, "First Board")
    {:ok, board_list} = Factory.create_board_list(board, "New Board List", "1")
    {:ok, _card} = Factory.create_card("Learn Elixir", "2 hours a day", board.id, board_list)

    {:ok, view, html} = live(auth_conn, "boards/#{board.id}")

    assert html =~ "First Board"
    assert has_element?(view, "#board-lists", "New Board List")
    assert has_element?(view, "#cards", "Learn Elixir")
  end

  test "does not show new card component when page loaded", %{auth_conn: auth_conn, user: user} do
    {:ok, board} = Factory.create_board(user, "First Board")
    {:ok, view, html} = live(auth_conn, "boards/#{board.id}")

    refute has_element?(view, "#new-card-modal", "Add Card")
  end

  test "opens new card modal when selecting Add a card link", %{auth_conn: auth_conn, user: user} do
    {:ok, board} = Factory.create_board(user, "First Board")
    {:ok, board_list} = Factory.create_board_list(board, "New Board List", "1")

    {:ok, view, html} = live(auth_conn, "boards/#{board.id}")

    view
    |> element("#add-new-card-button", "+ Add a card")
    |> render_click()

    assert has_element?(view, "#new-card-modal", "Add Card")
  end

  test "submitting a new-card-form adds it to the necessary board list", %{auth_conn: auth_conn, user: user} do
    # {:ok, board} = Factory.create_board(user, "First Board")
    # {:ok, board_list} = Factory.create_board_list(board, "New Board List", "1")

    # {:ok, view, html} = live(auth_conn, "boards/#{board.id}")


    # view
    # |> element("#add-new-card-button", "+ Add a card")
    # |> render_click()
    # |> form("#new-card-form", card: %{name: "This is a new card", description: "This is a new card description"})
    # |> render_submit()

    # assert has_element?(view, "#cards", "This is a new card")
  end

  test "invalid new-card-form returns error", %{auth_conn: auth_conn, user: user} do

  end

  defp guardian_sign_in_user(conn, user_id) do
    Guardian.Plug.sign_in(conn, %User{id: user_id})
  end

  defp add_token_to_session(conn) do
    Plug.Test.init_test_session(conn, guardian_default_token: conn.private.guardian_default_token)
  end
end
