defmodule TodoWeb.SharedBoardController do
  use TodoWeb, :controller
  alias Todo.{Boards, Boards.Board}
  import Guardian.Plug, only: [current_resource: 1]

  def index(conn, _params) do
    render(conn, "index.html", boards: user_boards(conn))
  end

  defp user_boards(conn) do
    Boards.list_shared_boards_for_user(current_resource(conn).id)
  end
end
