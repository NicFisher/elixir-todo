defmodule TodoWeb.BoardListController do
  use TodoWeb, :controller
  alias Todo.{Boards, Boards.BoardList}
  import Guardian.Plug, only: [current_resource: 1]

  def new(conn, %{"board_id" => board_id}) do
    board = Boards.get_board!(board_id, current_resource(conn).id)
    render(conn, "new.html", changeset: Boards.change_board_list(%BoardList{board: board}))
  end

  def create(conn, %{"board_id" => board_id, "board_list" => board_list}) do
    board = Boards.get_board!(board_id, current_resource(conn).id)

    case Boards.create_board_list(board_list, board) do
      {:ok, _board} ->
        conn
        |> put_flash(:info, "New Board List Created")
        |> redirect(to: "/boards/#{board_id}")

      {:error, _changeset} ->
        conn |> put_flash(:error, "Invalid details.") |> new(%{"board_id" => board_id})
    end
  end

  def edit(conn, %{"board_id" => board_id, "id" => id}) do
    board_list_changeset =
      Boards.get_board_list!(id, board_id, current_resource(conn).id)
      |> Boards.change_board_list()

    render(conn, "edit.html", changeset: board_list_changeset)
  end

  def update(conn, %{"board_list" => attrs, "id" => id, "board_id" => board_id}) do
    case update_board_list(conn, attrs, id, board_id) do
      {:ok, _board} ->
        conn
        |> put_flash(:info, "Board List Updated")
        |> redirect(to: "/boards/#{board_id}")

      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> put_flash(:error, "Invalid details.")
        |> render("edit.html", changeset: changeset, id: id)

      {:error, _error} ->
        conn
        |> put_flash(:error, "Oops, something went wrong.")
        |> render("index.html", boards: user_boards(conn))
    end
  end

  defp update_board_list(conn, attrs, id, board_id) do
    Boards.get_board_list!(id, board_id, current_resource(conn).id)
    |> Boards.update_board_list(attrs)
  end

  defp user_boards(conn) do
    Boards.list_boards_for_user(current_resource(conn).id)
  end
end
