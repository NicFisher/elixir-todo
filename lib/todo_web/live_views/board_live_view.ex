defmodule TodoWeb.BoardLiveView do
  alias Todo.Accounts.Guardian
  alias Todo.Boards
  alias TodoWeb.Router.Helpers, as: Routes
  use Phoenix.LiveView

  def render(assigns) do
    Phoenix.View.render(TodoWeb.BoardView, "show.html", assigns)
  end

  def mount(%{"id" => id}, %{"guardian_default_token" => token}, socket) do
    with {:ok, user} <- Guardian.user_from_token(token),
         board = Boards.get_board!(id, user.id),
         changeset = Boards.change_board(board) do
      {:ok,
       assign(socket,
         board: board,
         user: user,
         changeset: changeset,
         edit_board_link: Routes.board_path(socket, :edit, board.id),
         new_list_link: Routes.list_path(socket, :new, board.id),
         show_archive_board_link: true,
         edit_list_path: "/boards/"
       )}
    end
  end

  def mount(%{"shared_board_id" => id}, %{"guardian_default_token" => token}, socket) do
    with {:ok, user} <- Guardian.user_from_token(token),
         board = Boards.get_shared_board!(id, user.id),
         changeset = Boards.change_board(board) do
      {:ok,
       assign(socket,
         board: board,
         user: user,
         changeset: changeset,
         edit_board_link: Routes.shared_board_path(socket, :edit, board.id),
         new_list_link: Routes.shared_board_list_path(socket, :new, board.id),
         show_archive_board_link: false,
         edit_list_path: "/shared-boards/boards/"
       )}
    end
  end

  def handle_info({:refresh_board}, %{assigns: %{board: board}} = socket) do
    board = Todo.Boards.get_board!(board.id, board.user_id)

    {:noreply, assign(socket, board: board)}
  end

  def handle_event(
        "display-archive-board-component",
        %{"id" => id},
        %{assigns: %{board: board}} = socket
      ) do
    send_update(TodoWeb.ArchiveBoardComponent,
      id: id,
      board: board,
      modal_state: "display",
      action: "display-archive-card-component"
    )

    {:noreply, socket}
  end
end
