defmodule TodoWeb.LiveViewBoardTest do
  use TodoWeb.ConnCase
  alias Todo.Accounts.{User, Guardian}
  alias Todo.Accounts
  import Phoenix.ConnTest
  import Phoenix.LiveViewTest
  alias Todo.Factory

  setup %{conn: conn} do
    {:ok, user} = Factory.create_user()
    {:ok, board} = Factory.create_board(user, "First Board")
    {:ok, list} = Factory.create_list(board, "New List", "1")

    Accounts.authenticate_user("email@email.com", "password")

    auth_conn =
      conn
      |> guardian_sign_in_user(user.id)
      |> add_token_to_session()

    {:ok, auth_conn: auth_conn, conn: conn, user: user, board: board, list: list}
  end

  test "displays board, list and cards", %{
    auth_conn: auth_conn,
    board: board,
    list: list
  } do
    {:ok, _card} = Factory.create_card("Do something", "The description", list)
    {:ok, view, html} = live(auth_conn, "boards/#{board.id}")

    assert html =~ "First Board"
    assert has_element?(view, "#lists", "New List")
    assert has_element?(view, "#cards-1", "Do something")
  end

  describe "new card modal" do
    test "does not show new card component when page loaded", %{
      auth_conn: auth_conn,
      board: board
    } do
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
      |> open_new_card_modal()

      assert has_element?(view, "#new-card-modal", "Add Card")
    end

    test "submitting a new-card-form creates card and adds it to the board", %{
      auth_conn: auth_conn,
      board: board
    } do
      {:ok, view, _html} = live(auth_conn, "boards/#{board.id}")

      view
      |> open_new_card_modal()
      |> submit_new_card_form(%{name: "This is a new card", description: "description"})

      assert has_element?(view, "#cards-1", "This is a new card")
    end

    test "invalid new-card-form returns error", %{auth_conn: auth_conn, board: board} do
      {:ok, view, _html} = live(auth_conn, "boards/#{board.id}")

      view
      |> open_new_card_modal()
      |> submit_new_card_form(%{name: "", description: ""})

      assert has_element?(view, "#new-card-modal", "Invalid details")
    end
  end

  describe "edit card modal" do
    test "does not show edit card component when page loaded", %{
      auth_conn: auth_conn,
      board: board
    } do
      {:ok, view, _html} = live(auth_conn, "boards/#{board.id}")

      assert view
             |> element("#edit-modal-overlay")
             |> render() =~ "class=\"hidden"
    end

    test "opens edit card modal when selecting a card", %{
      auth_conn: auth_conn,
      board: board,
      list: list
    } do
      {:ok, card} = Factory.create_card("Some task", "The description", list)
      {:ok, view, _html} = live(auth_conn, "boards/#{board.id}")

      view
      |> element("##{card.id}", "Some task")
      |> render_click()

      assert has_element?(view, "#edit-card-modal", "Update Card")
    end

    test "submitting a edit-card-form updates card and the board", %{
      auth_conn: auth_conn,
      board: board,
      list: list
    } do
      {:ok, card} = Factory.create_card("Some task", "The description", list)
      {:ok, view, _html} = live(auth_conn, "boards/#{board.id}")

      view
      |> open_edit_card_modal(card)
      |> submit_edit_card_form(%{name: "Updated name", description: "Updated description"})

      assert has_element?(view, "#cards-1", "Updated name")
    end

    test "invalid new-card-form returns error", %{auth_conn: auth_conn, board: board, list: list} do
      {:ok, card} = Factory.create_card("Some task", "The description", list)
      {:ok, view, _html} = live(auth_conn, "boards/#{board.id}")

      view
      |> open_edit_card_modal(card)
      |> submit_edit_card_form(%{name: "", description: ""})

      assert has_element?(view, "#edit-card-modal", "Invalid details")
    end
  end

  describe "archive card modal" do
    test "does not show archive card component when page loaded", %{
      auth_conn: auth_conn,
      board: board
    } do
      {:ok, view, _html} = live(auth_conn, "boards/#{board.id}")

      assert view
             |> element("#archive-modal-overlay")
             |> render() =~ "class=\"hidden"
    end

    test "opens archive card modal when selecting cross on the card", %{
      auth_conn: auth_conn,
      board: board,
      list: list
    } do
      {:ok, card} = Factory.create_card("Some task", "The description", list)
      {:ok, view, _html} = live(auth_conn, "boards/#{board.id}")

      view
      |> element("#archive-#{card.id}")
      |> render_click()

      assert has_element?(
               view,
               "#archive-card-modal",
               "Are you sure you want to archive this card?"
             )
    end

    test "submitting a archive-card-form archives the card and updates the board", %{
      auth_conn: auth_conn,
      board: board,
      list: list
    } do
      {:ok, card} = Factory.create_card("Some task", "The description", list)
      {:ok, view, _html} = live(auth_conn, "boards/#{board.id}")

      assert has_element?(view, "#cards-1", "Some task")

      view
      |> open_archive_card_modal(card)
      |> submit_archive_card_form()

      refute has_element?(view, "#cards-1", "Some task")
    end
  end

  defp open_new_card_modal(view) do
    view
    |> element("#add-new-card-button", "+ Add a card")
    |> render_click()

    view
  end

  defp open_edit_card_modal(view, card) do
    view
    |> element("##{card.id}", card.name)
    |> render_click()

    view
  end

  defp open_archive_card_modal(view, card) do
    view
    |> element("#archive-#{card.id}")
    |> render_click()

    view
  end

  defp submit_new_card_form(view, values) do
    view
    |> form("#new-card-form", card: values)
    |> render_submit()

    view
  end

  defp submit_edit_card_form(view, values) do
    view
    |> form("#edit-card-form", card: values)
    |> render_submit()

    view
  end

  defp submit_archive_card_form(view) do
    view
    |> form("#archive-card-form")
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
