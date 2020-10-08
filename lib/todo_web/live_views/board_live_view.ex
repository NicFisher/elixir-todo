defmodule TodoWeb.BoardLiveView do
  use Phoenix.LiveView

  def render(assigns) do
    Phoenix.View.render(TodoWeb.BoardView, "show.html", assigns)
  end

  def mount(%{"id" => id}, %{"guardian_default_token" => token}, socket) do
    # TODO - Move this to a seperate module
    {:ok, claims} = Todo.Accounts.Guardian.decode_and_verify(token)
    {:ok, user} = Todo.Accounts.Guardian.resource_from_claims(claims)

    board = Todo.Boards.get_board!(id, user.id)
    changeset = Todo.Boards.change_board(board)

    {:ok, assign(socket, board: board, user: user, changeset: changeset)}
  end

  def handle_info({:card_created}, %{assigns: %{board: board}} = socket) do
    board = Todo.Boards.get_board!(board.id, board.user_id)

    {:noreply, assign(socket, board: board)}
  end
end
