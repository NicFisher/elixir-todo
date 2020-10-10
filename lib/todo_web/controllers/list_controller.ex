defmodule TodoWeb.ListController do
  use TodoWeb, :controller
  alias Todo.{Boards, Boards.List}
  import Guardian.Plug, only: [current_resource: 1]

  def new(conn, %{"board_id" => board_id}) do
    board = Boards.get_board!(board_id, current_resource(conn).id)
    render(conn, "new.html", changeset: Boards.change_list(%List{board: board}))
  end

  def create(conn, %{"board_id" => board_id, "list" => list}) do
    board = Boards.get_board!(board_id, current_resource(conn).id)

    case Boards.create_list(list, board) do
      {:ok, _multi} ->
        conn
        |> put_flash(:info, "New List Created")
        |> redirect(to: "/boards/#{board_id}")

      {:error, error} ->
        conn |> put_flash(:error, error) |> new(%{"board_id" => board_id})
    end
  end

  def edit(conn, %{"board_id" => board_id, "id" => id}) do
    list_changeset =
      Boards.get_list!(id, board_id, current_resource(conn).id)
      |> Boards.change_list()

    render(conn, "edit.html", changeset: list_changeset)
  end

  def update(conn, %{"list" => attrs, "id" => id, "board_id" => board_id}) do
    case update_list(conn, attrs, id, board_id) do
      {:ok, _board} ->
        conn
        |> put_flash(:info, "List Updated")
        |> redirect(to: "/boards/#{board_id}")

      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> put_flash(:error, "Invalid details.")
        |> render("edit.html", changeset: changeset, id: id)

      {:error, _error} ->
        conn
        |> put_flash(:error, "Oops, something went wrong.")
        |> redirect(to: "/boards/#{board_id}")
    end
  end

  defp update_list(conn, attrs, id, board_id) do
    Boards.get_list!(id, board_id, current_resource(conn).id)
    |> Boards.update_list(attrs)
  end
end
