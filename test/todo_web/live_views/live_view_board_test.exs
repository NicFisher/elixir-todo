defmodule TodoWeb.LiveViewBoardTest do
  use TodoWeb.ConnCase
  alias Todo.Boards
  alias Todo.Accounts.{User, Guardian}
  alias Todo.Accounts
  import Phoenix.ConnTest
  import Phoenix.LiveViewTest
  alias Todo.Factory

  setup %{conn: conn} do
    {:ok, user} = Factory.create_user()
    {:ok, board} = Factory.create_board(user, "First Board")
    {:ok, board_list} = Factory.create_board_list(board, "New Board List", "1")

    Accounts.authenticate_user("email@email.com", "password")

    auth_conn =
      conn
      |> guardian_sign_in_user(user.id)
      |> add_token_to_session()

    {:ok, auth_conn: auth_conn, conn: conn, user: user, board: board, board_list: board_list}
  end

  test "displays board, board list and cards", %{
    auth_conn: auth_conn,
    board: board,
    board_list: board_list,
    user: user
  } do
    {:ok, _card} = Factory.create_card("Do something", "The description", board_list)
    {:ok, view, html} = live(auth_conn, "boards/#{board.id}")

    Boards.get_board!(board.id, user.id) |> IO.inspect

    assert html =~ "First Board"
    assert has_element?(view, "#board-lists", "New Board List")
    assert has_element?(view, "#cards", "Do something")
  end

  test "does not show new card component when page loaded", %{auth_conn: auth_conn, board: board} do
    {:ok, view, _html} = live(auth_conn, "boards/#{board.id}")

    assert view
           |> element("#new-modal-overlay")
           |> render() =~ "class=\"hidden"
  end

  test "opens new card modal when selecting Add a card link", %{
    auth_conn: auth_conn,
    board: board
  } do
    {:ok, view, _html} = live(auth_conn, "boards/#{board.id}")

    view
    |> element("#add-new-card-button", "+ Add a card")
    |> render_click()

    assert has_element?(view, "#new-card-modal", "Add Card")
  end

  test "submitting a new-card-form creates card and adds it to the board", %{
    auth_conn: auth_conn,
    board: board
  } do
    {:ok, view, _html} = live(auth_conn, "boards/#{board.id}")

    view
    |> open_new_card_modal()
    |> submit_card_form(%{name: "This is a new card", description: "description"})

    assert has_element?(view, "#cards", "This is a new card")
  end

  test "invalid new-card-form returns error", %{auth_conn: auth_conn, board: board} do
    {:ok, view, _html} = live(auth_conn, "boards/#{board.id}")

    view
    |> open_new_card_modal()
    |> submit_card_form(%{name: "", description: ""})

    assert has_element?(view, "#new-card-modal", "Invalid details")
  end

  defp open_new_card_modal(view) do
    view
    |> element("#add-new-card-button", "+ Add a card")
    |> render_click()

    view
  end

  defp submit_card_form(view, values) do
    view
    |> form("#new-card-form", card: values)
    |> render_submit()

    view
  end

  defp guardian_sign_in_user(conn, user_id) do
    Guardian.Plug.sign_in(conn, %User{id: user_id})
  end

  defp add_token_to_session(conn) do
    Plug.Test.init_test_session(conn, guardian_default_token: conn.private.guardian_default_token)
  end
end
