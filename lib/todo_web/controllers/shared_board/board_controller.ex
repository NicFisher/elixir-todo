defmodule TodoWeb.SharedBoard.BoardController do
  use TodoWeb, :controller
  alias Todo.{Boards, Boards.Board}
  import Guardian.Plug, only: [current_resource: 1]

  def index(conn, _params) do
    render(conn, "index.html", boards: user_boards(conn))
  end

  def edit(conn, %{"id" => id}) do
    changeset = Boards.change_board(get_board(conn, id))
    render(conn, "edit.html", changeset: changeset, id: id)
  end

  def update(conn, %{"board" => attrs, "id" => id}) do
    case update_board(conn, attrs, id) do
      {:ok, _board} ->
        conn
        |> put_flash(:info, "Board Updated")
        |> redirect(to: "/shared-boards/boards")

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

  defp get_board(conn, id) do
    Boards.get_shared_board!(id, current_resource(conn).id)
  end

  defp user_boards(conn) do
    Boards.list_shared_boards_for_user(current_resource(conn).id)
  end

  defp update_board(conn, attrs, id) do
    case get_board(conn, id) do
      nil -> {:error, %Board{}}
      board -> Boards.update_board(board, attrs)
    end
  end
end
