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

  def handle_info({:card_created, card} = assigns, %{assigns: %{board: %{board_lists: board_lists} = board }} = socket) do
    {board_list, index} =
      board_lists
      |> Enum.with_index
      |> Enum.find(fn {bl, i} -> bl.id == card.board_list_id end)

    new_board_list = %{board_list | cards: [card | board_list.cards]}

    new_board = %{board | board_lists: List.replace_at(board.board_lists, index, new_board_list)}

    {:noreply, assign(socket, board: new_board)}
  end
end
