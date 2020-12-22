defmodule TodoWeb.ShareBoardTokenController do
  use TodoWeb, :controller
  alias Todo.ShareBoardTokens.CreateShareBoardToken
  alias Todo.BoardUsers.CreateBoardUser
  alias Todo.{Boards, Boards.ShareBoardToken, Boards.BoardUser}
  import Guardian.Plug, only: [current_resource: 1]

  def new(conn, _params) do
    render_new(conn)
  end

  def index(conn, _params) do
    render_new(conn)
  end

  def activate(conn, %{"token" => token}) do
    with {:ok, %BoardUser{board_id: board_id}} <-
           CreateBoardUser.create(token, current_resource(conn).id) do
      conn
      |> put_flash(:info, "Board has been shared.")
      |> redirect(to: "/shared-boards/boards/#{board_id}")
    else
      {:error, error} ->
        conn
        |> put_flash(:error, error)
        |> redirect(to: "/shared-boards/boards")
    end
  end

  def create(conn, %{
        "share_board_token" => %{"board_id" => board_id, "user_email" => shared_user_email}
      }) do
    with {:ok, _} <-
           CreateShareBoardToken.create(board_id, shared_user_email, current_resource(conn).id) do
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
    render(conn, "new.html",
      boards: user_boards(conn),
      changeset: Boards.change_share_board_token(%ShareBoardToken{})
    )
  end

  defp user_boards(conn) do
    Boards.list_boards_for_user(current_resource(conn).id)
  end
end
