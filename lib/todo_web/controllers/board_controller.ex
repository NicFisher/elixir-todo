defmodule TodoWeb.BoardController do
  use TodoWeb, :controller
  alias Todo.{Boards, Boards.Board}
  import Guardian.Plug, only: [current_resource: 1]

  def new(conn, _params) do
    render(conn, "new.html", changeset: Boards.change_board(%Board{}))
  end

  def index(conn, _params) do
    render(conn, "index.html", boards: user_boards(conn))
  end

  def create(conn, %{"board" => board}) do
    case Boards.create_board(board, current_resource(conn)) do
      {:ok, _board} ->
        conn
        |> put_flash(:info, "Board Created")
        |> render("index.html", boards: user_boards(conn))

      {:error, _changeset} ->
        conn |> put_flash(:error, "Oops, something went wrong.") |> new(%{})
    end
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
        |> redirect(to: "/boards")

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

  defp user_boards(conn) do
    Boards.list_boards_for_user(current_resource(conn).id)
  end

  defp get_board(conn, id) do
    Boards.get_only_board!(id, current_resource(conn).id)
  end

  defp update_board(conn, attrs, id) do
    case get_board(conn, id) do
      nil -> {:error, %Board{}}
      board -> Boards.update_board(board, attrs)
    end
  end
end
