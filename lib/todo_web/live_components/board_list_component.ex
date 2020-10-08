defmodule TodoWeb.BoardListComponent do
  use Phoenix.LiveComponent

  def render(assigns) do
    Phoenix.View.render(TodoWeb.BoardListView, "board_list_component.html", assigns)
  end

  def handle_event("display-new-board-list-component", %{"id" => id}, socket) do
    send_update(TodoWeb.NewCardComponent, id: id, modal_state: "display")
    {:noreply, socket}
  end
end
