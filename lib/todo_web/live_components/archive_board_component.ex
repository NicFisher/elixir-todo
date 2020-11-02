defmodule TodoWeb.ArchiveBoardComponent do
  use Phoenix.LiveComponent
  alias Todo.Boards
  alias Todo.Boards.Board

  def render(assigns) do
    Phoenix.View.render(TodoWeb.BoardView, "archive_board_component.html", assigns)
  end

  def mount(socket) do
    {:ok,
     assign(socket, modal_state: "hidden", error: false, changeset: Boards.change_board(%Board{}))}
  end

  def update(
        %{action: "display-archive-board-component", modal_state: modal_state, card: card},
        socket
      ) do
    {:ok, assign(socket, modal_state: modal_state, card: card)}
  end

  def update(assigns, socket) do
    {:ok, assign(socket, assigns)}
  end

  def handle_event("hide-archive-board-component", _params, socket) do
    {:noreply, assign(socket, modal_state: "hidden")}
  end

  def handle_event("update", %{"board" => attrs}, %{assigns: %{board: board}} = socket) do
    with {:ok, updated_board} <-
           Todo.Boards.update_board(board, attrs) do
     {:noreply, redirect(socket, to: "/boards")}
    else
      _error ->
        {:noreply,
         assign(socket, error: true, changeset: Boards.change_card(socket.assigns.card, attrs))}
    end
  end
end
