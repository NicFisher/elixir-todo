defmodule TodoWeb.BoardController do
  use TodoWeb, :controller
  alias Todo.{Boards, Boards.Board}

  def index(conn, _params) do
    render(conn, "index.html", boards: user_boards(conn))
  end

  def new(conn, _params) do
    render(conn, "new.html", changeset: Boards.change_board(%Board{}))
  end

  def create(conn, %{"board" => board}) do
    case Boards.create_board(board, Guardian.Plug.current_resource(conn)) do
      # value -> require IEx; IEx.pry
      {:ok, _board} -> conn |> put_flash(:info, "Board Created") |> render("index.html", boards: user_boards(conn))
      {:error, _changeset} -> conn |> put_flash(:error, "Oops, something went wrong.") |> new(%{})
    end
  end

  defp user_boards(conn) do
    Boards.list_boards_for_user(Guardian.Plug.current_resource(conn).id)
  end
end
