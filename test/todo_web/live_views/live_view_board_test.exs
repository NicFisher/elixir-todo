defmodule TodoWeb.LiveViewBoardTest do
  use TodoWeb.ConnCase
  use ExUnit.Case, async: true
  alias Todo.Accounts.{User, Guardian}
  alias Todo.Accounts
  import Phoenix.ConnTest
  import Phoenix.LiveViewTest
  alias Todo.{Factory, Repo}

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

  describe "show board" do
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

    test "archived board does not show lists", %{
      auth_conn: auth_conn,
      board: board
    } do
      {:ok, updated_board} = Todo.Boards.update_board(board, %{archived: true})
      {:ok, _view, html} = live(auth_conn, "boards/#{updated_board.id}")

      assert html =~ "First Board has been archived"
    end

    test "select Archive Board opens modal", %{
      auth_conn: auth_conn,
      board: board
    } do
      {:ok, view, _html} = live(auth_conn, "boards/#{board.id}")

      view
      |> open_archive_board_modal(board)

      assert has_element?(
               view,
               "#archive-board-modal",
               "Are you sure you want to archive this board?"
             )
    end

    test "Archiving the board updates the board to archived and shows board index page", %{
      auth_conn: auth_conn,
      board: board
    } do
      {:ok, view, _html} = live(auth_conn, "boards/#{board.id}")

      view
      |> open_archive_board_modal(board)
      |> submit_archive_board_form

      assert_redirected(view, "/boards")

      board = Todo.Repo.get_by(Todo.Boards.Board, id: board.id)
      assert board.archived == true
    end
  end

  describe "new card modal" do
    test "does not show new card component when page loaded", %{
      auth_conn: auth_conn,
      board: board
    } do
      {:ok, view, _html} = live(auth_conn, "boards/#{board.id}")

      assert view
             |> element("#new-card-modal-overlay-1")
             |> render() =~ "class=\"hidden"
    end

    test "opens new card modal when selecting Add a card link", %{
      auth_conn: auth_conn,
      board: board
    } do
      {:ok, view, _html} = live(auth_conn, "boards/#{board.id}")

      view
      |> open_new_card_modal()

      assert has_element?(view, "#new-card-modal-1", "Add Card")
      assert has_element?(view, "#new-card-modal-1", "+ Add due date")
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

    test "submitting a new-card-form with date creates card with due date and adds it to the board",
         %{
           auth_conn: auth_conn,
           board: board
         } do
      {:ok, view, _html} = live(auth_conn, "boards/#{board.id}")

      view
      |> open_new_card_modal()
      |> click_add_due_date("#new-card-modal-1")
      |> submit_new_card_form(%{
        name: "New card with due date",
        description: "description",
        due_date: %{day: "1", month: "1", year: "2020"}
      })

      [card] = Repo.all(Todo.Boards.Card)
      {:ok, due_date} = Date.new(2020, 1, 1)

      assert has_element?(view, "#cards-1", "New card with due date")
      assert card.due_date == due_date
    end

    test "invalid new-card-form returns error", %{auth_conn: auth_conn, board: board} do
      {:ok, view, _html} = live(auth_conn, "boards/#{board.id}")

      view
      |> open_new_card_modal()
      |> submit_new_card_form(%{name: "", description: ""})

      assert has_element?(view, "#new-card-modal-1", "Invalid details")
    end
  end

  describe "edit card modal" do
    test "does not show edit card component when page loaded", %{
      auth_conn: auth_conn,
      board: board
    } do
      {:ok, view, _html} = live(auth_conn, "boards/#{board.id}")

      assert view
             |> element("#edit-card-modal-overlay-1")
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

      assert has_element?(view, "#edit-card-modal-1", "Update Card")
      assert has_element?(view, "#edit-card-modal-1", "+ Add due date")
    end

    test "shows due date on edit card modal if due date exists on card", %{
      auth_conn: auth_conn,
      board: board,
      list: list
    } do
      {:ok, card} =
        Factory.create_card("Some task", "The description", list, %{
          day: "1",
          month: "1",
          year: "2020"
        })

      {:ok, view, _html} = live(auth_conn, "boards/#{board.id}")

      view
      |> element("##{card.id}", "Some task")
      |> render_click()

      assert has_element?(view, "#edit-card-modal-1", "Update Card")
      refute has_element?(view, "#edit-card-modal-1", "+ Add due date")
      assert has_element?(view, "#edit-card-modal-1", "Due date")
    end

    test "submitting a edit-card-form with due_date updates card and the board", %{
      auth_conn: auth_conn,
      board: board,
      list: list
    } do
      {:ok, card} =
        Factory.create_card("Some task", "The description", list, %{
          day: "1",
          month: "1",
          year: "2020"
        })

      {:ok, view, _html} = live(auth_conn, "boards/#{board.id}")

      view
      |> open_edit_card_modal(card)
      |> submit_edit_card_form(%{
        name: "Updated name",
        description: "Updated description",
        due_date: %{day: "1", month: "1", year: "2021"}
      })

      card = Repo.get_by(Todo.Boards.Card, id: card.id)
      {:ok, due_date} = Date.new(2021, 1, 1)

      assert has_element?(view, "#cards-1", "Updated name")
      assert card.name == "Updated name"
      assert card.description == "Updated description"
      assert card.due_date == due_date
    end

    test "selecting Add due date on edit-card-modal shows due date input", %{
      auth_conn: auth_conn,
      board: board,
      list: list
    } do
      {:ok, card} = Factory.create_card("Some task", "The description", list)
      {:ok, view, _html} = live(auth_conn, "boards/#{board.id}")

      view
      |> open_edit_card_modal(card)
      |> click_add_due_date("#edit-card-modal-1")

      assert has_element?(view, "#edit-card-modal-1", "Due date")
    end

    test "submitting a edit-card-form updates card and the board", %{
      auth_conn: auth_conn,
      board: board,
      list: list
    } do
      {:ok, card} =
        Factory.create_card("Some task", "The description", list, %{
          day: "1",
          month: "1",
          year: "2020"
        })

      {:ok, view, _html} = live(auth_conn, "boards/#{board.id}")

      view
      |> open_edit_card_modal(card)
      |> submit_edit_card_form(%{
        name: "Updated name",
        description: "Updated description",
        due_date: %{day: "1", month: "1", year: "2021"}
      })

      card = Repo.get_by(Todo.Boards.Card, id: card.id)
      {:ok, due_date} = Date.new(2021, 1, 1)

      assert has_element?(view, "#cards-1", "Updated name")
      assert card.name == "Updated name"
      assert card.description == "Updated description"
      assert card.due_date == due_date
    end

    test "invalid new-card-form returns error", %{auth_conn: auth_conn, board: board, list: list} do
      {:ok, card} = Factory.create_card("Some task", "The description", list)
      {:ok, view, _html} = live(auth_conn, "boards/#{board.id}")

      view
      |> open_edit_card_modal(card)
      |> submit_edit_card_form(%{name: "", description: ""})

      assert has_element?(view, "#edit-card-modal-1", "Invalid details")
    end
  end

  describe "archive card modal" do
    test "does not show archive card component when page loaded", %{
      auth_conn: auth_conn,
      board: board
    } do
      {:ok, view, _html} = live(auth_conn, "boards/#{board.id}")

      assert view
             |> element("#archive-card-modal-overlay-1")
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
      |> element("#archive-card-#{card.id}")
      |> render_click()

      assert has_element?(
               view,
               "#archive-card-modal-1",
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

  describe "shared board - show" do
    test "displays shared board, list and cards", %{
      auth_conn: auth_conn,
      board: board,
      list: list,
      user: user
    } do
      {:ok, _board_user} = Factory.create_board_user(user.id, board.id)
      {:ok, _card} = Factory.create_card("Do something", "The description", list)
      {:ok, view, html} = live(auth_conn, "/shared-boards/boards/#{board.id}")

      assert html =~ "First Board"
      assert has_element?(view, "#lists", "New List")
      assert has_element?(view, "#cards-1", "Do something")
    end

    test "raises error if board user does not exist between board and user", %{
      auth_conn: auth_conn,
      board: board,
      list: list
    } do
      {:ok, _card} = Factory.create_card("Do something", "The description", list)

      assert_raise(Ecto.NoResultsError, fn ->
        raise live(auth_conn, "/shared-boards/boards/#{board.id}")
      end)
    end

    test "archived board does not show lists", %{
      auth_conn: auth_conn,
      board: board,
      user: user
    } do
      {:ok, _board_user} = Factory.create_board_user(user.id, board.id)
      {:ok, updated_board} = Todo.Boards.update_board(board, %{archived: true})
      {:ok, _view, html} = live(auth_conn, "shared-boards/boards/#{updated_board.id}")

      assert html =~ "First Board has been archived"
    end

    test "Archive Board button does not show for shared user", %{
      auth_conn: auth_conn,
      board: board,
      user: user
    } do
      {:ok, _board_user} = Factory.create_board_user(user.id, board.id)
      {:ok, view, _html} = live(auth_conn, "shared-boards/boards/#{board.id}")

      refute has_element?(
               view,
               "#archive-board-#{board.id}",
               "Are you sure you want to archive this board?"
             )
    end
  end

  describe "shared board - new card modal" do
    test "does not show new card component when page loaded", %{
      auth_conn: auth_conn,
      board: board,
      user: user
    } do
      {:ok, _board_user} = Factory.create_board_user(user.id, board.id)
      {:ok, view, _html} = live(auth_conn, "shared-boards/boards/#{board.id}")

      assert view
             |> element("#new-card-modal-overlay-1")
             |> render() =~ "class=\"hidden"
    end

    test "opens new card modal when selecting Add a card link", %{
      auth_conn: auth_conn,
      board: board,
      user: user
    } do
      {:ok, _board_user} = Factory.create_board_user(user.id, board.id)
      {:ok, view, _html} = live(auth_conn, "shared-boards/boards/#{board.id}")

      view
      |> open_new_card_modal()

      assert has_element?(view, "#new-card-modal-1", "Add Card")
    end

    test "submitting a new-card-form creates card and adds it to the board", %{
      auth_conn: auth_conn,
      board: board,
      user: user
    } do
      {:ok, _board_user} = Factory.create_board_user(user.id, board.id)
      {:ok, view, _html} = live(auth_conn, "shared-boards/boards/#{board.id}")

      view
      |> open_new_card_modal()
      |> submit_new_card_form(%{name: "This is a new card", description: "description"})

      assert has_element?(view, "#cards-1", "This is a new card")
    end

    test "invalid new-card-form returns error", %{auth_conn: auth_conn, board: board, user: user} do
      {:ok, _board_user} = Factory.create_board_user(user.id, board.id)
      {:ok, view, _html} = live(auth_conn, "shared-boards/boards/#{board.id}")

      view
      |> open_new_card_modal()
      |> submit_new_card_form(%{name: "", description: ""})

      assert has_element?(view, "#new-card-modal-1", "Invalid details")
    end
  end

  describe "shared board - edit card modal" do
    test "does not show edit card component when page loaded", %{
      auth_conn: auth_conn,
      board: board,
      user: user
    } do
      {:ok, _board_user} = Factory.create_board_user(user.id, board.id)
      {:ok, view, _html} = live(auth_conn, "shared-boards/boards/#{board.id}")

      assert view
             |> element("#edit-card-modal-overlay-1")
             |> render() =~ "class=\"hidden"
    end

    test "opens edit card modal when selecting a card", %{
      auth_conn: auth_conn,
      board: board,
      list: list,
      user: user
    } do
      {:ok, _board_user} = Factory.create_board_user(user.id, board.id)
      {:ok, card} = Factory.create_card("Some task", "The description", list)
      {:ok, view, _html} = live(auth_conn, "shared-boards/boards/#{board.id}")

      view
      |> element("##{card.id}", "Some task")
      |> render_click()

      assert has_element?(view, "#edit-card-modal-1", "Update Card")
    end

    test "submitting a edit-card-form updates card and the board", %{
      auth_conn: auth_conn,
      board: board,
      list: list,
      user: user
    } do
      {:ok, _board_user} = Factory.create_board_user(user.id, board.id)
      {:ok, card} = Factory.create_card("Some task", "The description", list)
      {:ok, view, _html} = live(auth_conn, "shared-boards/boards/#{board.id}")

      view
      |> open_edit_card_modal(card)
      |> submit_edit_card_form(%{name: "Updated name", description: "Updated description"})

      assert has_element?(view, "#cards-1", "Updated name")
    end

    test "invalid new-card-form returns error", %{
      auth_conn: auth_conn,
      board: board,
      list: list,
      user: user
    } do
      {:ok, _board_user} = Factory.create_board_user(user.id, board.id)
      {:ok, card} = Factory.create_card("Some task", "The description", list)
      {:ok, view, _html} = live(auth_conn, "shared-boards/boards/#{board.id}")

      view
      |> open_edit_card_modal(card)
      |> submit_edit_card_form(%{name: "", description: ""})

      assert has_element?(view, "#edit-card-modal-1", "Invalid details")
    end
  end

  defp open_new_card_modal(view) do
    view
    |> element("#add-new-card-button", "+ Add a card")
    |> render_click()

    view
  end

  defp click_add_due_date(view, modal_id) do
    view
    |> element("#{modal_id} .add-due-date", "+ Add due date")
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
    |> element("#archive-card-#{card.id}")
    |> render_click()

    view
  end

  defp open_archive_board_modal(view, board) do
    view
    |> element("#archive-board-#{board.id}")
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

  defp submit_archive_board_form(view) do
    view
    |> form("#archive-board-form")
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
