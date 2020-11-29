defmodule TodoWeb.ShareBoardTokenController do
  use TodoWeb, :controller
  alias Todo.{Boards, Boards.Board, Boards.ShareBoardToken}
  import Guardian.Plug, only: [current_resource: 1]

  def new(conn, _params) do
    render_new(conn)
  end

  def index(conn, _params) do
    render_new(conn)
  end

  def create(conn, %{"share_board_token" => %{"board_id" => board_id, "user_email" => shared_user_email}}) do
    with {:ok, _} <- CreateShareBoardToken.create(board_id, shared_user_email, current_resource(conn).id) do
      conn
      |> put_flash(:info, "Board has been shared with #{shared_user_email}")
      |> render_new
    else
      {:error, message} ->
        conn
        |> put_flash(:error, message)
        |> render_new
    end
  end

  defp render_new(conn) do
    render(conn, "new.html", boards: user_boards(conn), changeset: Boards.change_share_board_token(%ShareBoardToken{}))
  end

  defp user_boards(conn) do
    Boards.list_boards_for_user(current_resource(conn).id)
  end

  defp board_belongs_to_current_user("", _), do: {:error, "Board must be selected"}

  defp board_belongs_to_current_user(board_id, conn) do
    case Todo.Repo.get_by(Board, [id: board_id, user_id: current_resource(conn).id]) do
      %Board{} = board -> {:ok, board}
      _ -> {:error, "Board does not belong to current user"}
    end
  end
end
